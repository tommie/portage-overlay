# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools git-r3

EGIT_REPO_URI="https://github.com/cisco/cjose.git"
EGIT_COMMIT="${PV}"

DESCRIPTION="C library implementing the Javascript Object Signing and Encryption (JOSE)"
HOMEPAGE="https://github.com/cisco/cjose"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="
	>=dev-libs/openssl-1.1.1d
	>=dev-libs/jansson-2.11"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( >=app-doc/doxygen-1.8 )
	test? ( >=dev-libs/check-0.9.4 )"
