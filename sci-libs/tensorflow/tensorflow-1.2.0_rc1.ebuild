# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5} )
DISTUTILS_OPTIONAL=1
EGO_PN=github.com/tensorflow/tensorflow/tensorflow/go

inherit distutils-r1 epatch golang-build

from_bazel_uri() {
    echo "$1" | while read url mark pkg strip_prefix extra; do
        echo "${url} -> ${pkg}-$(sha256sum <<<"${url}" | cut -d' ' -f1)-${url##*/}"
    done
}

pythonx_for_best_impl() {
    python_setup
    local MULTIBUILD_VARIANT="${EPYTHON/./_}"
    local BUILD_DIR="${S}-${MULTIBUILD_VARIANT}"

    "$@"
}

# bazel_uri is updated with bazelexternals, not manually.
bazel_uri="http://mirror.bazel.build/github.com/google/boringssl/archive/bbcaa15b0647816b9a1a9b9e0d209cd6712f0105.tar.gz => boringssl boringssl-bbcaa15b0647816b9a1a9b9e0d209cd6712f0105
           http://mirror.bazel.build/github.com/google/re2/archive/b94b7cd42e9f02673cd748c1ac1d16db4052514c.tar.gz => com_googlesource_code_re2 re2-b94b7cd42e9f02673cd748c1ac1d16db4052514c
           http://mirror.bazel.build/curl.haxx.se/download/curl-7.49.1.tar.gz => curl curl-7.49.1 third_party/curl.BUILD
           https://github.com/mbostock-bower/d3-bower/archive/v3.5.15.tar.gz => d3 d3-bower-3.5.15 bower.BUILD
           https://github.com/cpettitt/dagre/archive/v0.7.4.tar.gz => dagre dagre-0.7.4 bower.BUILD
           http://mirror.bazel.build/bitbucket.org/eigen/eigen/get/f3a22f35b044.tar.gz => eigen_archive eigen-eigen-f3a22f35b044 third_party/eigen.BUILD
           https://github.com/components/es6-promise/archive/v2.1.0.tar.gz => es6_promise es6-promise-2.1.0 bower.BUILD
           http://mirror.bazel.build/github.com/google/farmhash/archive/92e897b282426729f4724d91a637596c7e2fe28f.zip => farmhash_archive farmhash-92e897b282426729f4724d91a637596c7e2fe28f third_party/farmhash.BUILD
           http://mirror.bazel.build/www.kurims.kyoto-u.ac.jp/~ooura/fft.tgz => fft2d . third_party/fft2d/fft2d.BUILD
           https://github.com/polymerelements/font-roboto/archive/v1.0.1.tar.gz => font_roboto font-roboto-1.0.1 bower.BUILD
           http://mirror.bazel.build/github.com/google/gemmlowp/archive/a6f29d8ac48d63293f845f2253eccbf86bc28321.tar.gz => gemmlowp gemmlowp-a6f29d8ac48d63293f845f2253eccbf86bc28321
           http://mirror.bazel.build/ufpr.dl.sourceforge.net/project/giflib/giflib-5.1.4.tar.gz => gif_archive giflib-5.1.4 third_party/gif.BUILD
           https://github.com/cpettitt/graphlib/archive/v1.0.7.tar.gz => graphlib graphlib-1.0.7 bower.BUILD
           http://mirror.bazel.build/github.com/grpc/grpc/archive/d7ff4ff40071d2b486a052183e3e9f9382afb745.tar.gz => grpc grpc-d7ff4ff40071d2b486a052183e3e9f9382afb745 third_party/grpc.BUILD
           http://mirror.bazel.build/github.com/google/highwayhash/archive/dfcb97ca4fe9277bf9dc1802dd979b071896453b.tar.gz => highwayhash highwayhash-dfcb97ca4fe9277bf9dc1802dd979b071896453b third_party/highwayhash.BUILD
           http://mirror.bazel.build/github.com/bazelbuild/rules_closure/archive/aac19edc557aec9b603cd7ffe359401264ceff0d.tar.gz => io_bazel_rules_closure rules_closure-aac19edc557aec9b603cd7ffe359401264ceff0d
           https://github.com/polymerelements/iron-a11y-announcer/archive/v1.0.5.tar.gz => iron_a11y_announcer iron-a11y-announcer-1.0.5 bower.BUILD
           https://github.com/polymerelements/iron-a11y-keys-behavior/archive/v1.1.8.tar.gz => iron_a11y_keys_behavior iron-a11y-keys-behavior-1.1.8 bower.BUILD
           https://github.com/polymerelements/iron-ajax/archive/v1.2.0.tar.gz => iron_ajax iron-ajax-1.2.0 bower.BUILD
           https://github.com/polymerelements/iron-autogrow-textarea/archive/v1.0.12.tar.gz => iron_autogrow_textarea iron-autogrow-textarea-1.0.12 bower.BUILD
           https://github.com/polymerelements/iron-behaviors/archive/v1.0.17.tar.gz => iron_behaviors iron-behaviors-1.0.17 bower.BUILD
           https://github.com/polymerelements/iron-checked-element-behavior/archive/v1.0.4.tar.gz => iron_checked_element_behavior iron-checked-element-behavior-1.0.4 bower.BUILD
           https://github.com/polymerelements/iron-collapse/archive/v1.0.8.tar.gz => iron_collapse iron-collapse-1.0.8 bower.BUILD
           https://github.com/polymerelements/iron-dropdown/archive/v1.4.0.tar.gz => iron_dropdown iron-dropdown-1.4.0 bower.BUILD
           https://github.com/polymerelements/iron-fit-behavior/archive/v1.2.5.tar.gz => iron_fit_behavior iron-fit-behavior-1.2.5 bower.BUILD
           https://github.com/polymerelements/iron-flex-layout/archive/v1.3.0.tar.gz => iron_flex_layout iron-flex-layout-1.3.0 bower.BUILD
           https://github.com/polymerelements/iron-form-element-behavior/archive/v1.0.6.tar.gz => iron_form_element_behavior iron-form-element-behavior-1.0.6 bower.BUILD
           https://github.com/polymerelements/iron-icon/archive/v1.0.11.tar.gz => iron_icon iron-icon-1.0.11 bower.BUILD
           https://github.com/polymerelements/iron-icons/archive/v1.1.3.tar.gz => iron_icons iron-icons-1.1.3 bower.BUILD
           https://github.com/polymerelements/iron-iconset-svg/archive/v1.1.0.tar.gz => iron_iconset_svg iron-iconset-svg-1.1.0 bower.BUILD
           https://github.com/polymerelements/iron-input/archive/1.0.10.tar.gz => iron_input iron-input-1.0.10 bower.BUILD
           https://github.com/polymerelements/iron-list/archive/v1.3.9.tar.gz => iron_list iron-list-1.3.9 bower.BUILD
           https://github.com/polymerelements/iron-menu-behavior/archive/v1.1.10.tar.gz => iron_menu_behavior iron-menu-behavior-1.1.10 bower.BUILD
           https://github.com/polymerelements/iron-meta/archive/v1.1.1.tar.gz => iron_meta iron-meta-1.1.1 bower.BUILD
           https://github.com/polymerelements/iron-overlay-behavior/archive/v1.10.1.tar.gz => iron_overlay_behavior iron-overlay-behavior-1.10.1 bower.BUILD
           https://github.com/polymerelements/iron-range-behavior/archive/v1.0.4.tar.gz => iron_range_behavior iron-range-behavior-1.0.4 bower.BUILD
           https://github.com/polymerelements/iron-resizable-behavior/archive/v1.0.3.tar.gz => iron_resizable_behavior iron-resizable-behavior-1.0.3 bower.BUILD
           https://github.com/polymerelements/iron-scroll-target-behavior/archive/v1.0.3.tar.gz => iron_scroll_target_behavior iron-scroll-target-behavior-1.0.3 bower.BUILD
           https://github.com/polymerelements/iron-selector/archive/v1.5.2.tar.gz => iron_selector iron-selector-1.5.2 bower.BUILD
           https://github.com/polymerelements/iron-validatable-behavior/archive/v1.1.1.tar.gz => iron_validatable_behavior iron-validatable-behavior-1.1.1 bower.BUILD
           http://mirror.bazel.build/github.com/jemalloc/jemalloc/archive/4.4.0.tar.gz => jemalloc jemalloc-4.4.0 third_party/jemalloc.BUILD
           http://mirror.bazel.build/github.com/libjpeg-turbo/libjpeg-turbo/archive/1.5.1.tar.gz => jpeg libjpeg-turbo-1.5.1 third_party/jpeg/jpeg.BUILD
           http://mirror.bazel.build/github.com/open-source-parsers/jsoncpp/archive/11086dd6a7eba04289944367ca82cea71299ed70.tar.gz => jsoncpp_git jsoncpp-11086dd6a7eba04289944367ca82cea71299ed70 third_party/jsoncpp.BUILD
           http://mirror.bazel.build/github.com/hfp/libxsmm/archive/1.8.tar.gz => libxsmm_archive libxsmm-1.8 third_party/libxsmm.BUILD
           http://mirror.bazel.build/github.com/llvm-mirror/llvm/archive/c978c0ff91f7c4ea58cfbd8f378e51c6af2c2b4b.tar.gz => llvm llvm-c978c0ff91f7c4ea58cfbd8f378e51c6af2c2b4b third_party/llvm/llvm.BUILD
           https://github.com/lodash/lodash/archive/3.8.0.tar.gz => lodash lodash-3.8.0 bower.BUILD
           http://mirror.bazel.build/github.com/nanopb/nanopb/archive/1251fa1065afc0d62f635e0f63fec8276e14e13c.tar.gz => nanopb_git nanopb-1251fa1065afc0d62f635e0f63fec8276e14e13c third_party/nanopb.BUILD
           http://mirror.bazel.build/www.nasm.us/pub/nasm/releasebuilds/2.12.02/nasm-2.12.02.tar.bz2 => nasm nasm-2.12.02 third_party/nasm.BUILD
           http://mirror.bazel.build/github.com/nvidia/nccl/archive/ccfc4567dc3e2a37fb42cfbc64d10eb526e7da7b.tar.gz => nccl_archive nccl-ccfc4567dc3e2a37fb42cfbc64d10eb526e7da7b third_party/nccl.BUILD
           https://github.com/polymerelements/neon-animation/archive/v1.2.2.tar.gz => neon_animation neon-animation-1.2.2 bower.BUILD
           https://cdnjs.cloudflare.com/ajax/libs/numeric/1.2.6/numeric.min.js -> numericjs_numeric_min_js .
           http://mirror.bazel.build/github.com/html5lib/html5lib-python/archive/0.9999999.tar.gz => org_html5lib html5lib-python-0.9999999 third_party/html5lib.BUILD
           http://mirror.bazel.build/github.com/mozilla/bleach/archive/v1.5.tar.gz => org_mozilla_bleach bleach-1.5 third_party/bleach.BUILD
           http://mirror.bazel.build/pypi.python.org/packages/b7/7f/44d3cfe5a12ba002b253f6985a4477edfa66da53787a2a838a40f6415263/Werkzeug-0.11.10.tar.gz => org_pocoo_werkzeug Werkzeug-0.11.10 third_party/werkzeug.BUILD
           http://mirror.bazel.build/pypi.python.org/packages/1d/25/3f6d2cb31ec42ca5bd3bfbea99b63892b735d76e26f20dd2dcc34ffe4f0d/Markdown-2.6.8.tar.gz => org_pythonhosted_markdown Markdown-2.6.8 third_party/markdown.BUILD
           https://github.com/polymerelements/paper-behaviors/archive/v1.0.12.tar.gz => paper_behaviors paper-behaviors-1.0.12 bower.BUILD
           https://github.com/polymerelements/paper-button/archive/v1.0.11.tar.gz => paper_button paper-button-1.0.11 bower.BUILD
           https://github.com/polymerelements/paper-checkbox/archive/v1.4.0.tar.gz => paper_checkbox paper-checkbox-1.4.0 bower.BUILD
           https://github.com/polymerelements/paper-dialog/archive/v1.0.4.tar.gz => paper_dialog paper-dialog-1.0.4 bower.BUILD
           https://github.com/polymerelements/paper-dialog-behavior/archive/v1.2.5.tar.gz => paper_dialog_behavior paper-dialog-behavior-1.2.5 bower.BUILD
           https://github.com/polymerelements/paper-dialog-scrollable/archive/1.1.5.tar.gz => paper_dialog_scrollable paper-dialog-scrollable-1.1.5 bower.BUILD
           https://github.com/polymerelements/paper-dropdown-menu/archive/v1.4.0.tar.gz => paper_dropdown_menu paper-dropdown-menu-1.4.0 bower.BUILD
           https://github.com/polymerelements/paper-header-panel/archive/v1.1.4.tar.gz => paper_header_panel paper-header-panel-1.1.4 bower.BUILD
           https://github.com/polymerelements/paper-icon-button/archive/v1.1.3.tar.gz => paper_icon_button paper-icon-button-1.1.3 bower.BUILD
           https://github.com/polymerelements/paper-input/archive/v1.1.18.tar.gz => paper_input paper-input-1.1.18 bower.BUILD
           https://github.com/polymerelements/paper-item/archive/v1.1.4.tar.gz => paper_item paper-item-1.1.4 bower.BUILD
           https://github.com/polymerelements/paper-listbox/archive/v1.1.2.tar.gz => paper_listbox paper-listbox-1.1.2 bower.BUILD
           https://github.com/polymerelements/paper-material/archive/v1.0.6.tar.gz => paper_material paper-material-1.0.6 bower.BUILD
           https://github.com/polymerelements/paper-menu/archive/v1.2.2.tar.gz => paper_menu paper-menu-1.2.2 bower.BUILD
           https://github.com/polymerelements/paper-menu-button/archive/v1.5.1.tar.gz => paper_menu_button paper-menu-button-1.5.1 bower.BUILD
           https://github.com/polymerelements/paper-progress/archive/v1.0.9.tar.gz => paper_progress paper-progress-1.0.9 bower.BUILD
           https://github.com/polymerelements/paper-radio-button/archive/v1.1.2.tar.gz => paper_radio_button paper-radio-button-1.1.2 bower.BUILD
           https://github.com/polymerelements/paper-radio-group/archive/v1.0.9.tar.gz => paper_radio_group paper-radio-group-1.0.9 bower.BUILD
           https://github.com/polymerelements/paper-ripple/archive/v1.0.5.tar.gz => paper_ripple paper-ripple-1.0.5 bower.BUILD
           https://github.com/polymerelements/paper-slider/archive/v1.0.10.tar.gz => paper_slider paper-slider-1.0.10 bower.BUILD
           https://github.com/polymerelements/paper-spinner/archive/v1.1.1.tar.gz => paper_spinner paper-spinner-1.1.1 bower.BUILD
           https://github.com/polymerelements/paper-styles/archive/v1.1.4.tar.gz => paper_styles paper-styles-1.1.4 bower.BUILD
           https://github.com/polymerelements/paper-tabs/archive/v1.7.0.tar.gz => paper_tabs paper-tabs-1.7.0 bower.BUILD
           https://github.com/polymerelements/paper-toast/archive/v1.3.0.tar.gz => paper_toast paper-toast-1.3.0 bower.BUILD
           https://github.com/polymerelements/paper-toggle-button/archive/v1.2.0.tar.gz => paper_toggle_button paper-toggle-button-1.2.0 bower.BUILD
           https://github.com/polymerelements/paper-toolbar/archive/v1.1.4.tar.gz => paper_toolbar paper-toolbar-1.1.4 bower.BUILD
           https://github.com/polymerelements/paper-tooltip/archive/v1.1.2.tar.gz => paper_tooltip paper-tooltip-1.1.2 bower.BUILD
           http://mirror.bazel.build/ftp.exim.org/pub/pcre/pcre-8.39.tar.gz => pcre pcre-8.39 third_party/pcre.BUILD
           https://github.com/palantir/plottable/archive/v1.16.1.tar.gz => plottable plottable-1.16.1 bower.BUILD
           http://mirror.bazel.build/github.com/glennrp/libpng/archive/v1.2.53.zip => png_archive libpng-1.2.53 third_party/png.BUILD
           https://github.com/polymer/polymer/archive/v1.7.0.tar.gz => polymer polymer-1.7.0 bower.BUILD
           https://github.com/polymerlabs/promise-polyfill/archive/v1.0.0.tar.gz => promise_polyfill promise-polyfill-1.0.0 bower.BUILD
           http://mirror.bazel.build/github.com/google/protobuf/archive/2b7430d96aeff2bb624c8d52182ff5e4b9f7f18a.tar.gz => protobuf protobuf-2b7430d96aeff2bb624c8d52182ff5e4b9f7f18a
           http://mirror.bazel.build/pypi.python.org/packages/source/s/six/six-1.10.0.tar.gz => six_archive six-1.10.0 third_party/six.BUILD
           http://mirror.bazel.build/github.com/google/snappy/archive/1.1.4.zip => snappy snappy-1.1.4 third_party/snappy.BUILD
           http://mirror.bazel.build/ufpr.dl.sourceforge.net/project/swig/swig/swig-3.0.8/swig-3.0.8.tar.gz => swig swig-3.0.8 third_party/swig.BUILD
           https://raw.githubusercontent.com/mrdoob/three.js/r77/examples/js/controls/OrbitControls.js -> three_js_orbitcontrols_js .
           https://raw.githubusercontent.com/mrdoob/three.js/r77/build/three.min.js -> three_js_three_min_js .
           https://github.com/web-animations/web-animations-js/archive/2.2.1.tar.gz => web_animations_js web-animations-js-2.2.1 bower.BUILD
           https://github.com/webcomponents/webcomponentsjs/archive/v0.7.22.tar.gz => webcomponentsjs webcomponentsjs-0.7.22 bower.BUILD
           https://raw.githubusercontent.com/waylonflinn/weblas/v0.9.0/dist/weblas.js -> weblas_weblas_js .
           http://mirror.bazel.build/zlib.net/zlib-1.2.8.tar.gz => zlib_archive zlib-1.2.8 third_party/zlib.BUILD"
DESCRIPTION="Computation framework using data flow graphs for scalable machine learning"
HOMEPAGE="https://www.tensorflow.org/"
SRC_URI="https://github.com/tensorflow/tensorflow/archive/v${PV/_rc/-rc}.tar.gz -> ${P}.tar.gz
         $(from_bazel_uri "${bazel_uri}")"
S="${WORKDIR}/${PN}-${PV/_rc/-rc}"

LICENSE="Apache-2.0 BSD BSD-2 ZLIB MIT MPL-2.0 IJG"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda gcp go hdfs jemalloc lib +python
	cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 cpu_flags_x86_sse4_1 cpu_flags_x86_sse4_2 cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_avx512f cpu_flags_x86_fma3 cpu_flags_x86_fma4"

RDEPEND="python? ( >=dev-python/numpy-1.11.0[${PYTHON_USEDEP}]
		>=dev-python/six-1.10.0[${PYTHON_USEDEP}]
		>=dev-python/wheel-0.26[${PYTHON_USEDEP}]
		>=dev-python/protobuf-python-3.1.0[${PYTHON_USEDEP}]
		>=dev-python/werkzeug-0.11.11[${PYTHON_USEDEP}] )"
# CUPTI is required, so cuda-toolkit needs profiler.
# patchelf >=0.9 has the --remove-rpath option.
DEPEND="${RDEPEND}
	>=dev-java/java-config-2.2.0-r3
	>=dev-util/bazel-0.4.5
	>=dev-util/patchelf-0.9
	app-arch/unzip
	cuda? ( >=dev-util/nvidia-cuda-toolkit-8.0.61[profiler]
		>=dev-libs/nvidia-cuda-cudnn-6.0 )
	go? ( >=dev-lang/go-1.7 )"

pkg_setup() {
	export JAVA_HOME=$(java-config --jre-home)
}

src_unpack() {
	default

	epatch "${FILESDIR}/bazel-markers-${PV}.patch"
}

src_prepare() {
	default

	local bazel_base="${WORKDIR}/bazel-base"
	echo "${bazel_uri}" | while read url mark pkg strip_prefix build_file extra; do
        	einfo "Installing prefetched //external:${pkg}..."
		if [ "x${mark}" = 'x->' ]; then
	        	local f="${DISTDIR}/${pkg}-$(sha256sum <<<"${url}" | cut -d' ' -f1)-${url##*/}"
			mkdir -p "${bazel_base}/external/${pkg}/file"
			cp "${f}" "${bazel_base}/external/${pkg}/${url##*/}" || die
			cp "${f}" "${bazel_base}/external/${pkg}/file/${url##*/}" || die
			(echo '# DO NOT EDIT: automatically generated BUILD.bazel file for http_file rule'
			 echo 'filegroup('
			 echo "    name = 'file',"
			 echo "    srcs = ['${url##*/}'],"
			 echo "    visibility = ['//visibility:public']"
			 echo ')') >"${bazel_base}/external/${pkg}/file/BUILD.bazel"
		else
			if [ "${strip_prefix}" != . ]; then
				# Bazel resolves some symlinks causing freshness checks to fail if using symlinks.
				#ln -fs "${WORKDIR}/${strip_prefix}" "${bazel_base}/external/${pkg}" || die
				cp -pr "${WORKDIR}/${strip_prefix}" "${bazel_base}/external/${pkg}" || die
			else
			    local p=${url##*/}
			    p=${p%.*}
			    #ln -fs "${WORKDIR}/${p%.*}" "${bazel_base}/external/${pkg}" || die
			    mkdir -p "${bazel_base}/external/${pkg}"
				cp -pr "${WORKDIR}/${p}" "${bazel_base}/external/${pkg}/${p}" || die
			fi
			if [ -n "${build_file}" ]; then
				# We could just link this, but need this replacement while
			    # Tensorflow uses temp_workaround_http_archive, which is a
			    # workaround for some Bazel bug.
			    sed 's/%ws%//g' "${S}/${build_file}" >"${bazel_base}/external/${pkg}/BUILD.bazel" || die
			fi
		fi
		if [ ! -e "${bazel_base}/external/${pkg}/WORKSPACE" ]; then
			(echo '# DO NOT EDIT: automatically generated WORKSPACE file for http_* rule'
			 echo "workspace(name = \"${pkg}\")") >"${bazel_base}/external/${pkg}/WORKSPACE"
		fi
	done

	epatch "${FILESDIR}/build_pip_package-1.0.1.patch"
	for f in third_party/gpus/cuda_configure.bzl third_party/py/python_configure.bzl; do
	    sed -i -e 's;\(implementation\s*=[^,]*\)\(,\?\)$;\1, local=True\2;' "${S}/${f}" || die
	done
	sed -i -e '/^bazel clean/ d' "${S}/configure" || die
	cat >>"${S}/configure" <<EOF
# Make Bazel extract embedded files.
bazel --output_base="\${BAZEL_OUTPUT_BASE}" --batch version >/dev/null || die

# Now make cc_configure a local repository so it works with --nofetch.
# Bazel dirty-checks files by mtime, so retain the original (which is set to today+10years).
d=\$(stat -c%Y "\${BAZEL_OUTPUT_BASE}/install/_embedded_binaries/embedded_tools/tools/cpp/cc_configure.bzl") || die
sed -i -e 's;implementation=_impl,\$;\0 local=True,;' "\${BAZEL_OUTPUT_BASE}/install/_embedded_binaries/embedded_tools/tools/cpp/cc_configure.bzl" || die
touch -d "@\${d}" "\${BAZEL_OUTPUT_BASE}/install/_embedded_binaries/embedded_tools/tools/cpp/cc_configure.bzl" || die

# Now "fetch" all @local* repositories.
# This needs to happen inside configure so Bazel saves the right environment variables.
bazel --output_base="\${BAZEL_OUTPUT_BASE}" --batch query --nofetch --noshow_loading_progress "filter('^@local', deps(//tensorflow/tools/pip_package:build_pip_package union //tensorflow:libtensorflow.so))" >/dev/null || die
EOF

	python_copy_sources

	do_copy_bazel_base() {
		cp -p -R "${WORKDIR}/bazel-base" "${WORKDIR}/bazel-base-${MULTIBUILD_VARIANT}"
	}

	python_foreach_impl do_copy_bazel_base
}

src_configure() {
	do_configure() {
		local bazel_base="${WORKDIR}/bazel-base-${MULTIBUILD_VARIANT}"
		local cc_opt_flags=( -march=native )
		
		# Keep this list in sync with tensorflow/core/platform/cpu_feature_guard.cc.
		! use cpu_flags_x86_sse || cc_opt_flags+=( -msse )
		! use cpu_flags_x86_sse2 || cc_opt_flags+=( -msse2 )
		! use cpu_flags_x86_sse3 || cc_opt_flags+=( -msse3 )
		! use cpu_flags_x86_sse4_1 || cc_opt_flags+=( -msse4.1 )
		! use cpu_flags_x86_sse4_2 || cc_opt_flags+=( -msse4.2 )
		! use cpu_flags_x86_avx || cc_opt_flags+=( -mavx )
		! use cpu_flags_x86_avx2 || cc_opt_flags+=( -mavx2 )
		! use cpu_flags_x86_avx512f || cc_opt_flags+=( -mavx512f )
		! use cpu_flags_x86_fma3 || cc_opt_flags+=( -mfma )
		! use cpu_flags_x86_fma4 || cc_opt_flags+=( -mfma4 )

		cd "${BUILD_DIR}" || die
		python_export PYTHON_SITEDIR
		BAZEL_OUTPUT_BASE="${bazel_base}" \
			CC_OPT_FLAGS="${cc_opt_flags[*]}" \
			TF_NEED_JEMALLOC=$(usex jemalloc 1 0) \
			TF_NEED_GCP=$(usex gcp 1 0) \
			TF_NEED_HDFS=$(usex hdfs 1 0) \
			TF_NEED_MKL=0 \
			TF_NEED_OPENCL=0 \
			TF_NEED_CUDA=$(usex cuda 1 0) \
			TF_NEED_VERBS=0 \
			GCC_HOST_COMPILER_PATH=/usr/bin/gcc \
			TF_CUDA_VERSION=8.0 \
			TF_CUDA_CLANG=0 \
			CUDA_TOOLKIT_PATH=/opt/cuda \
			TF_CUDNN_VERSION=6 \
			CUDNN_INSTALL_PATH=/usr \
			TF_CUDA_COMPUTE_CAPABILITIES="3.5,5.2" \
			TF_ENABLE_XLA=0 \
			PYTHON_BIN_PATH="${PYTHON}" \
			PYTHON_LIB_PATH="${PYTHON_SITEDIR}" \
			./configure || die
	}
	python_foreach_impl do_configure
}

src_compile() {
	if use python; then
		do_compile() {
			local bazel_base="${WORKDIR}/bazel-base-${MULTIBUILD_VARIANT}"
			cd "${BUILD_DIR}" || die
			bazel --output_base="${bazel_base}" --batch build --noshow_loading_progress --show_progress_rate_limit=30 --nofetch --compilation_mode=opt --config=opt $(usex cuda --config=cuda) //tensorflow/tools/pip_package:build_pip_package || die
		}
		python_foreach_impl do_compile
	fi

	if use lib; then
		do_libcompile() {
			local bazel_base="${WORKDIR}/bazel-base-${MULTIBUILD_VARIANT}"
			cd "${BUILD_DIR}" || die
			bazel --output_base="${bazel_base}" --batch build --noshow_loading_progress --show_progress_rate_limit=30 --nofetch --compilation_mode=opt --config=opt $(usex cuda --config=cuda) //tensorflow:libtensorflow.so || die
		}
		pythonx_for_best_impl do_libcompile
	fi

	if use go; then
        	do_gocompile() {
			cd "${BUILD_DIR}" || die
			mkdir -p src/github.com/tensorflow/tensorflow/tensorflow
			ln -fs "${BUILD_DIR}/tensorflow/go" src/github.com/tensorflow/tensorflow/tensorflow/ || die
			# Like golang-build_src_compile, but in BUILD_DIR.
			ego_pn_check
			GOPATH="${BUILD_DIR}:$(get_golibdir_gopath)" \
				LIBRARY_PATH="${LIBRARY_PATH}:${BUILD_DIR}/bazel-bin/tensorflow" \
				LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BUILD_DIR}/bazel-bin/tensorflow" \
				go install ${EGO_BUILD_FLAGS} "${EGO_PN}" || die
		}
		pythonx_for_best_impl do_gocompile
	fi
}

src_install() {
	if use python; then
		do_install() {
			(
				cd "${BUILD_DIR}" || die
				# Note this is patched to install rather than build.
				# Source it so we can use esetup.py.
				source bazel-bin/tensorflow/tools/pip_package/build_pip_package
			)
		}
		python_foreach_impl do_install

		dosym ../lib/python-exec/python-exec2 /usr/bin/saved_model_cli || die
		dosym ../lib/python-exec/python-exec2 /usr/bin/tensorboard || die
	fi

	if use lib; then
        	do_libinstall() {
			cd "${BUILD_DIR}" || die
			dolib bazel-bin/tensorflow/libtensorflow.so
		}
		pythonx_for_best_impl do_libinstall
	fi

	if use go; then
        	do_goinstall() {
			cd "${BUILD_DIR}" || die
			# Like golang_install_pkgs, but in BUILD_DIR.
			ego_pn_check
			insinto "$(get_golibdir)"
			insopts -m0644 -p # preserve timestamps for bug 551486
			doins -r "${BUILD_DIR}/pkg" "${BUILD_DIR}/src"
		}
		pythonx_for_best_impl do_goinstall
	fi

	dodoc AUTHORS CONTRIBUTING.md ISSUE_TEMPLATE.md README.md RELEASE.md

	local rpath newrpath
	for p in $(find "${ED}" -name \*.so); do
		rpath=$(patchelf --print-rpath "${p}") || die
		newrpath=$(sed -e 's;[^:]*/\(_solib_local\|local_config_[^/]*\)/[^:]*;;g' \
			       -e 's/:\+/:/g' \
			       -e 's/:$//' <<<"${rpath}") || die
		if [ "x${newrpath}" != "x${rpath}" ]; then
			einfo "Cleaning RUNPATH in ${p##*/}..."
			if [ -z "${newrpath}" ]; then
				patchelf --remove-rpath "${p}" || die
			else
				patchelf --set-rpath "${newrpath}" "${p}" || die
			fi
		fi
	done
	local soname
	# Setting SONAME in the Python files causes warnings from strip
	# about not having enough space...
	for p in $(find "${ED}" -name libtensorflow.so); do
		soname=$(patchelf --print-soname "${p}") || die
		if [ -z "${soname}" ]; then
			einfo "Setting SONAME in ${p##*/}..."
			patchelf --set-soname "$(basename "${p}")" "${p}" || die
		fi
	done
}
