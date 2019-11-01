# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( pypy3 python3_{6,7} )
inherit distutils-r1

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/tgbugs/ontquery.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="a framework querying ontology terms"
HOMEPAGE="https://github.com/tgbugs/ontquery"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="dev services test"
RESTRICT="!test? ( test )"

SVCDEPEND="
	>=dev-python/rdflib-5.0.0[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"
DEPEND="
	dev-python/setuptools
	dev? (
		>=dev-python/pyontutils-0.1.4[${PYTHON_USEDEP}]
	)
	services? (
		${SVCDEPEND}
	)
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-runner[${PYTHON_USEDEP}]
		${SVCDEPEND}
	)
"
RDEPEND="${DEPEND}"

if [[ ${PV} == "9999" ]]; then
	python_configure_all () {
			mydistutilsargs=( --release )
	}

	src_prepare () {
		# replace package version to keep python quiet
		sed -i "s/__version__.\+$/__version__ = '9999.0.0'/" ${PN}/__init__.py
		default
	}
fi

python_test() {
	distutils_install_for_testing
	cd "${TEST_DIR}" || die
	cp -r "${S}/test" . || die
	cp "${S}/setup.cfg" . || die
	PYTHONWARNINGS=ignore pytest -v --color=yes || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	local DOCS=( README* docs/* )
	distutils-r1_python_install_all
}
