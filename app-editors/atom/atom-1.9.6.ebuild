# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils

DESCRIPTION="This is a sample skeleton ebuild file"
HOMEPAGE="https://foo.example.org/"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${PN}-amd64.tar.gz -> ${P}-amd64.tar.gz
         https://raw.githubusercontent.com/${PN}/${PN}/v${PV}/resources/linux/${PN}.desktop.in -> ${P}.desktop.in"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
QA_PREBUILT="*"
DEPEND=""
RDEPEND=">=app-arch/bzip2-1.0.6-r7
         >=dev-libs/atk-2.18.0
         >=dev-libs/dbus-glib-0.102
         >=dev-libs/expat-2.1.1-r2
         >=dev-libs/glib-2.46.2-r3
         >=dev-libs/gmp-6.0.0a
         >=dev-libs/libffi-3.2.1
         >=dev-libs/libtasn1-4.5
         >=dev-libs/nettle-3.2
         >=dev-libs/nspr-4.12
         >=dev-libs/nss-3.23
         >=gnome-base/gconf-3.2.6-r4
         >=media-libs/alsa-lib-1.0.29
         >=media-libs/fontconfig-2.11.1-r2
         >=media-libs/freetype-2.6.3-r1
         >=media-libs/harfbuzz-1.2.7
         >=media-libs/libpng-1.6.21
         >=media-libs/mesa-11.0.6
         >=net-libs/gnutls-3.3.24
         >=net-print/cups-2.1.3-r1
         >=sys-apps/dbus-1.10.8-r1
         >=sys-apps/sandbox-2.10-r1
         >=sys-devel/gcc-4.9.3
         >=sys-libs/glibc-2.22-r4
         >=sys-libs/zlib-1.2.8-r1
         >=x11-libs/cairo-1.14.6
         >=x11-libs/gdk-pixbuf-2.32.3
         >=x11-libs/gtk+-2.24.30
         >=x11-libs/libdrm-2.4.65
         >=x11-libs/libnotify-0.7.6-r3
         >=x11-libs/libX11-1.6.3
         >=x11-libs/libXau-1.0.8
         >=x11-libs/libxcb-1.11.1
         >=x11-libs/libXcomposite-0.4.4-r1
         >=x11-libs/libXcursor-1.1.14
         >=x11-libs/libXdamage-1.1.4-r1
         >=x11-libs/libXdmcp-1.1.2
         >=x11-libs/libXext-1.3.3
         >=x11-libs/libXfixes-5.0.1
         >=x11-libs/libXi-1.7.5
         >=x11-libs/libXrandr-1.5.0
         >=x11-libs/libXrender-0.9.9
         >=x11-libs/libxshmfence-1.2
         >=x11-libs/libXtst-1.2.2
         >=x11-libs/libXxf86vm-1.1.4
         >=x11-libs/pango-1.38.1
         >=x11-libs/pixman-0.32.8"
S=${WORKDIR}/${P}-amd64


find_all_elf() {
	find . -name lib\*.so -o \( -type f -executable \) | while read f; do if [[ "$(file "$f")" == *ELF* ]]; then echo "$f"; fi; done
}

packages_for_libs() {
	# ldd warns about lib*.so not being executable.
	xargs ldd 2>/dev/null \
	| awk '$3 && $3 !~ /libnode|libffmpeg/ { print $3; }' \
	| while read lib; do
		pkg=$(fgrep -l "$lib" /var/db/pkg/*/*/CONTENTS | cut -d/ -f5-6)
		if [ -z "$pkg" ]; then
			echo "$lib missing" >&2
		else
			echo "$pkg"
		fi
	done \
	| sort -u
}

diff_rdepends() {
	diff -uw \
		<(sed -e 's/^.*>=\(.*\)-[0-9].*/\1/' <<<"${RDEPEND}" | sort) \
		<(find_all_elf | packages_for_libs | sed -e 's/^\(.*\)-[0-9].*/\1/')
}

src_compile() {
	diff_rdepends || die "the downloaded installation depends on library files not available on the system"

	chmod ugo+x "${S}/chromedriver/chromedriver" || die "Failed to chmod chromedriver"

	# Values from packages.json.
	sed \
		-e 's;<%= appName %>;Atom;' \
		-e 's;<%= description %>;A hackable text editor for the 21st Century.;' \
		-e "s;<%= installDir %>/share/<%= appFileName %>;/opt/${P};" \
		-e "s;<%= iconPath %>;/opt/${P}/${PN}.png;" \
		"${DISTDIR}/${P}.desktop.in" >"${WORKDIR}/${PN}.desktop" || die "Failed to create ${PN}.desktop"
}

src_install() {
	install -d "${D}/opt/${P}"
	cp -pr "${S}"/* "${D}/opt/${P}/"

	dosym "../../opt/${P}/atom" usr/bin/atom
	insinto /usr/share/applications
	doins "${WORKDIR}/${PN}.desktop"
}
