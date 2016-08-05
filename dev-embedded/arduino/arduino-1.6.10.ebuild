# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Development environment for the Arduino family of microcontroller boards"
HOMEPAGE="https://arduino.cc/"
SRC_URI="https://www.arduino.cc/download_handler.php?f=/${P}-linux64.tar.xz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="fetch strip"
#DEPEND=""
RDEPEND="${DEPEND}"

QA_PREBUILT="opt/${P}/hardware/*
             opt/${P}/libraries/*"


src_install() {
	install -d -m 0755 "${D}/opt/${P}"
	cp -pr "${S}" "${D}/opt/"
        rm "${D}/opt/${P}/install.sh" "${D}/opt/${P}/uninstall.sh"
        newenvd "${FILESDIR}/${P}.env" "50${P}"
}
