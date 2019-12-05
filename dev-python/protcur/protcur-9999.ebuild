# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( pypy3 python3_{6,7} )
inherit distutils-r1 user

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/tgbugs/protc.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Web annotation workflows for protocol curation."
HOMEPAGE="https://github.com/tgbugs/protc/tree/master/protcur"

LICENSE="MIT"
SLOT="0"
IUSE="dev test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/htmlfn[${PYTHON_USEDEP}]
	>=dev-python/hyputils-0.0.4[${PYTHON_USEDEP}]
	dev-python/markdown[${PYTHON_USEDEP}]
	>=dev-python/pyontutils-0.1.9[${PYTHON_USEDEP}]
	>=dev-python/pysercomb-0.0.3[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev? (
		dev-python/pytest-cov[${PYTHON_USEDEP}]
		dev-python/wheel[${PYTHON_USEDEP}]
	)
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-runner[${PYTHON_USEDEP}]
	)
"
RDEPEND="${DEPEND}"

pkg_setup() {
	ebegin "Creating protcur user and group"
	enewgroup ${PN}
	enewuser ${PN} -1 -1 "/var/lib/${PN}" ${PN}
	eend $?
}

if [[ ${PV} == "9999" ]]; then
	S="${S}/${PN}"
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
	esetup.py install_data --install-dir="${TEST_DIR}"
	cd "${TEST_DIR}" || die
	cp -r "${S}/test" . || die
	cp "${S}/setup.cfg" . || die
	PYTHONWARNINGS=ignore pytest -v --color=yes || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	local DOCS=( README* )
	distutils-r1_python_install_all
}

src_install() {
	keepdir "/var/log/${PN}"
	fowners ${PN}:${PN} "/var/log/${PN}"
	newinitd "${S}/resources/protcur.rc" protcur
	newconfd "${S}/resources/protcur.confd" protcur
	chmod 0600 "${D}"/etc/conf.d/*
	distutils-r1_src_install
}

pkg_postinst() {
	ewarn "In order to run protcur you need to set the hypothes.is"
	ewarn "group, user, and api token in /etc/conf.d/protcur"
}
