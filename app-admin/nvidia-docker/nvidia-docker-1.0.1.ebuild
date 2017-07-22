# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

einherit golang-build

DESCRIPTION="NVIDIA Docker"
HOMEPAGE="https://github.com/NVIDIA/nvidia-docker"
SRC_URI="https://github.com/NVIDIA/nvidia-docker/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="NVIDIA CORPORATION"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-libs/nvidia-cuda-toolkit-8.0
	app-emulation/docker
"
RDEPEND="${DEPEND}"

src_compile() {
	export CGO_CFLAGS "-I /usr/local/cuda-6.5/include -I /usr/include/nvidia/gdk"
	export CGO_LDFLAGS "-L /usr/local/cuda-6.5/lib64"
	golang-build_src_compile
}

src_install() {
	go install -v -ldflags="-s -X main.Version=${PV}" ./...
	emake prefix="${D}/usr" install
}
