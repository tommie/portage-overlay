# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit apache-module git-r3

EGIT_REPO_URI="https://github.com/pingidentity/mod_auth_openidc.git"
EGIT_COMMIT="v${PV}"

DESCRIPTION="OpenID Connect Relying Party and OAuth 2.0 Resource Server for Apache HTTP Server 2.x"
HOMEPAGE="https://github.com/pingidentity/mod_auth_openidc/wiki"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="redis"

RDEPEND="net-misc/curl
	dev-libs/openssl
	dev-libs/apr
	dev-libs/jansson
	dev-libs/libpcre
	redis? ( dev-libs/hiredis )"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig"

APACHE2_MOD_CONF="10_mod_auth_openidc"
APACHE2_MOD_DEFINE="AUTH_OPENIDC"
DOCFILES="README.md"

need_apache2

src_configure() {
	./autogen.sh
	econf \
		--with-apxs2="${APXS}" \
		$(use_with redis hiredis)
}

src_compile() {
	emake
}
