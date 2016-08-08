# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 )
inherit eutils distutils-r1

DESCRIPTION="An open source ecosystem for IoT development"
HOMEPAGE="https://platformio.org/"
SRC_URI="https://pypi.python.org/packages/6e/09/204d1e5638e50897093ca2b2d9f58ccf268ef486c527bda5cf2f9348eb19/${P}.tar.gz"


LICENSE="Apache"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
#RESTRICT="strip"

DEPEND="dev-python/setuptools"
RDEPEND=""
