# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( pypy{,3} python{2_7,3_{5,6,7}} )
inherit distutils-r1

DESCRIPTION="A test fixtures replacement based on thoughtbot's factory_bot for Ruby."
HOMEPAGE="https://github.com/FactoryBoy/factory_boy"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	>=dev-python/faker-0.7.0[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

RESTRICT="test"
