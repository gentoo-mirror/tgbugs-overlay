# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( pypy3 python3_{6,7} )
inherit distutils-r1

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/tgbugs/augpathlib.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Augmented pathlib."
HOMEPAGE="https://github.com/tgbugs/augpathlib"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="dev test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-python/git-python[${PYTHON_USEDEP}]
	>=dev-python/pexpect-4.7.0[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/pyxattr[${PYTHON_USEDEP}]
	dev-python/terminaltables[${PYTHON_USEDEP}]
	|| ( sys-apps/file[python,${PYTHON_USEDEP}] dev-python/python-magic[${PYTHON_USEDEP}] )
	dev? (
		dev-python/pytest-cov[${PYTHON_USEDEP}]
	)
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-runner[${PYTHON_USEDEP}]
	)
"
RDEPEND="${DEPEND}"

src_prepare () {
	# replace package version to keep python quiet
	sed -i "s/__version__.\+$/__version__ = '9999.0.0'/" ${PN}/__init__.py
	# remove python-magic from setup.py deps since it may not always be installed
	sed -i "/python-magic/d" setup.py  # workaround for testing for just 0.0.2
	default
}

python_test() {
	distutils_install_for_testing
	cd "${TEST_DIR}" || die
	cp -r "${S}/test" . || die
	cp "${S}/setup.cfg" . || die
	PYTHONWARNINGS=ignore pytest -v --color=yes || die "Tests fail with ${EPYTHON}"
}
