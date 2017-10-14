#!/usr/bin/python3
"""A program to extract externals from a Bazel workspace.

Example:

  bazelexternals tensorflow-1.0.ebuild .

To update tensorflow-1.0.ebuild with externals from the workspace in $PWD.
The ebuild file must have an assignment like

  bazel_uri="..."

possibly spanning multiple lines. This will be replaced with new sources. A file
called files/bazel-markers-1.0.patch will be created that contains the marker
files in the Bazel base directory, needed because generating the fingerprints
is difficult from outside the Bazel code and markers may contain arbitrary
information.

Note that the output is dependent on Bazel version, so make sure to require
at least the version of Bazel used here.
"""

import argparse
import collections
import difflib
import hashlib
import os.path
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

import portage.versions as versions


FilegroupExternal = collections.namedtuple("FilegroupExternal", ["name", "urls", "strip_prefix", "marker", "basename"])
HttpArchive = collections.namedtuple("HttpArchive", ["name", "urls", "strip_prefix", "marker", "build_file"])
HttpFile = collections.namedtuple("HttpFile", ["name", "urls", "strip_prefix", "marker"])


def marker_name(name):
    """Returns a marker filename for an external repository."""
    return "@{}.marker".format(name.replace("//external:", ""))


def label_to_path(label):
    """Returns the path of a source file identified by label."""
    return label.lstrip("/").replace(":", os.path.sep)


def uri_record(c):
    """Generates a URI record for the ebuild file.

    @param c an HttpArchive or HttpFile.
    @return a line to be inserted into bazel_uri.
    """
    args = [c.urls[0]]
    mrk = "=>"
    if isinstance(c, HttpFile):
        mrk = "->"
    elif isinstance(c, FilegroupExternal):
        mrk = "-->"
    args.extend([mrk, c.name.replace("//external:", ""), c.strip_prefix or "."])
    if isinstance(c, HttpArchive) and c.build_file:
        args.append(label_to_path(c.build_file))
    return " ".join(args)


def get_externals(workspace, targets, repository_rules):
    """Find all external repositories reachable from the given input targets.

    @param workspace str, path to the workspace directory.
    @param targets iterable of str, list of root targets to query.
    @param repository_rules iterable of str, list of repository rule types to look for.
    @return list of HttpArchive or HttpFile
    """
    repository_rules = set(repository_rules)

    # Figure out where the cache directory is for this workspace.
    output_base = subprocess.check_output(["bazel", "info", "--config=opt", "output_base"], cwd=workspace).decode("utf-8").rstrip()

    # Find all external dependencies of the input targets.
    extdeps = set()
    for l in subprocess.check_output([
            "bazel",
            "query", "--output", "label", "--nofetch", "--config=opt",
            "filter('//external:|@', deps({}))".format(" union ".join(targets))], cwd=workspace).splitlines():
        l = l.decode("utf-8").strip("'").strip()
        if l.startswith("//external:"):
            extdeps.add(l)
        else:
            extdeps.add("//external:" + l[1:].split("//")[0])

    # Get details about the repositories.
    xml = subprocess.check_output([
        "bazel",
        "query", "--output", "xml", "--nofetch", "--config=opt",
        "kind('filegroup_external|git_repository|http_archive|http_file|maven_jar|maven_server rule', //external:*)"], cwd=workspace)
    rules = ET.fromstring(xml)
    deps = []
    for r in rules.iter("rule"):
        name = r.get("name")
        if name not in extdeps:
            continue

        sp = r.find("string[@name='strip_prefix']")
        sp = sp.get("value") if sp is not None else None
        build_file = r.find("string[@name='build_file']")
        build_file = build_file.get("value") if build_file is not None else None
        if not build_file:
            build_file = r.find("label[@name='build_file']")
            build_file = build_file.get("value") if build_file is not None else None
        if r.get("class") not in repository_rules:
            raise ValueError("unimplemented rule type {}".format(r.get("class")))

        urls = []
        for u in r.findall("list[@name='urls']/string"):
            urls.append(u.get("value"))
        for u in r.findall("string[@name='url']"):
            urls.append(u.get("value"))

        with open(os.path.join(output_base, "external", marker_name(name)), "r") as f:
            # The temp_workaround_http_archive rule causes the copied build_file
            # to be checked against a checksum. That would have been fine if the mtime
            # wasn't part of the checksum. We really don't care.
            marker = [l for l in f.read().splitlines(True)
                      if not l.startswith("FILE:")]

        if r.get("class") == "filegroup_external":
            # This can have multiple URLs per rule.
            for file in r.findall("dict[@name='sha256_urls']/pair"):
                urls = [u.get("value") for u in file.findall("list/string")]
                rename = r.find("string[@name='rename']")
                basename = rename.get("value") if rename is not None else urls[0].rsplit("/", 1)[-1]
                deps.append(FilegroupExternal(name, urls, None, marker, basename))
            if r.findall("dict[@name='sha256_urls_extract']/pair"):
                raise NotImplementedError("Found filegroup_external with sha256_urls_extract: {}".format(name))
        elif r.get("class") == "http_file":
            deps.append(HttpFile(name, urls, sp, marker))
        else:
            deps.append(HttpArchive(name, urls, sp, marker, build_file))

    return sorted(deps, key=lambda x: x.name)


def update_ebuild_file(deps, path):
    """Update the ebuild in-place with new source URIs.

    @param deps iterable of HttpArchive or HttpFile, the externals.
    @param path str, path to the ebuild file. Must exist.
    """
    try:
        with open(path, "rt") as inf, tempfile.NamedTemporaryFile('wt', prefix=os.path.basename(path), dir=os.path.dirname(path), delete=False) as outf:
            discard = False
            for l in inf:
                if l.strip().startswith("bazel_uri=\""):
                    print("bazel_uri=\"" + "\n           ".join(uri_record(d) for d in deps) + "\"", file=outf)
                    discard = True
                if not discard:
                    print(l.rstrip(), file=outf)
                if discard and l.rstrip().endswith("\""):
                    discard = False

        shutil.copymode(path, outf.name)
    except:
        os.unlink(outf.name)
        raise
    else:
        os.rename(outf.name, path)


def write_markers_file(deps, path):
    """Create a patch file that would create marker files as they exist in the current Bazel cache.

    @param deps iterable of HttpArchive or HttpFile, the externals.
    @param path str, path to the output file.
    """
    try:
        with open(path, "wt") as outf:
            for d in deps:
                outf.writelines(difflib.unified_diff(
                    b"", d.marker,
                    fromfile=os.path.join("bazel-base", "external", marker_name(d.name)),
                    tofile=os.path.join("bazel-base", "external", marker_name(d.name))))
    except:
        os.unlink(path)
        raise


def main():
    argp = argparse.ArgumentParser()
    argp.add_argument("--targets", type=str, action="append", default=["//tensorflow/tools/pip_package:build_pip_package", "//tensorflow:libtensorflow.so", "@io_bazel_rules_closure//closure:defs.bzl"], help="Targets to extract dependencies from")
    argp.add_argument("--repository_rules", type=str, action="append", default=["filegroup_external", "http_archive", "http_file", "new_http_archive", "patched_http_archive", "temp_workaround_http_archive"], help="Repository rule types to include")
    argp.add_argument("ebuild", type=str, help="Ebuild file to update")
    argp.add_argument("workspace", type=str, help="Bazel workspace directory")
    args = argp.parse_args()

    if not os.path.exists(args.ebuild):
        raise ValueError("ebuild file does not exist")

    pn, pv, r = versions.pkgsplit(os.path.basename(args.ebuild)[:-7])

    os.environ.update(dict(
        CC_OPT_FLAGS="-mnative -msse -msse2 -msse3",
        TF_NEED_JEMALLOC="1",
        TF_NEED_GCP="1",
        TF_NEED_HDFS="1",
        TF_NEED_MKL="0",
        TF_NEED_MPI="0",
        TF_NEED_OPENCL="0",
        TF_NEED_CUDA="1",
        TF_NEED_VERBS="0",
        GCC_HOST_COMPILER_PATH="/usr/bin/gcc",
        TF_CUDA_VERSION="8.0",
        TF_CUDA_CLANG="0",
        CUDA_TOOLKIT_PATH="/opt/cuda",
        TF_CUDNN_VERSION="6",
        CUDNN_INSTALL_PATH="/usr",
        TF_CUDA_COMPUTE_CAPABILITIES="3.5,5.2,6.1",
        TF_ENABLE_XLA="0",
        PYTHON_BIN_PATH="/usr/bin/python3.4",
        PYTHON_LIB_PATH="/usr/lib64/python3.4/site-packages"))
    subprocess.check_call(["./configure"], cwd=args.workspace)

    # Get external repositories.
    subprocess.check_call(["bazel", "fetch", "--config=opt"] + args.targets, cwd=args.workspace)
    deps = get_externals(args.workspace, args.targets, args.repository_rules)

    # Update the ebuild source URIs.
    update_ebuild_file(deps, args.ebuild)

    # Create a patch file with markers.
    filesdir = os.path.join(os.path.dirname(args.ebuild), "files")
    if not os.path.exists(filesdir):
        os.makedirs(filesdir)
    write_markers_file(deps, os.path.join(filesdir, "bazel-markers-{}.patch".format(pv)))

if __name__ == "__main__":
    main()
