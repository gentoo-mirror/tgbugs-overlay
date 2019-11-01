# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( pypy3 python3_{6,7} )

inherit distutils-r1 user

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/SciCrunch/scibot.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Web annotation curation pipeline"
HOMEPAGE="https://github.com/SciCrunch/scibot"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="dev test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-python/beautifulsoup:4[${PYTHON_USEDEP}]
	dev-python/curio[${PYTHON_USEDEP}]
	dev-python/docopt[${PYTHON_USEDEP}]
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/gevent[$(python_gen_usedep python3_{6,7})]
	www-servers/gunicorn[${PYTHON_USEDEP}]
	>=dev-python/hyputils-0.0.4[memex,${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	>=dev-python/pyontutils-0.1.4[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

pkg_setup() {
	ebegin "Creating scibot user and group"
	enewgroup ${PN}
	enewuser ${PN} -1 -1 "/var/lib/${PN}" ${PN}
	eend $?
}

src_prepare () {
	# replace package version to keep python quiet
	sed -i "s/__version__.\+$/__version__ = '9999.0.0'/" ${PN}/__init__.py
	default
}

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

src_install() {
	keepdir "/var/log/${PN}"
	fowners ${PN}:${PN} "/var/log/${PN}"
	newinitd "${FILESDIR}/scibot-bookmarklet.rc" scibot-bookmarklet
	newconfd "${FILESDIR}/scibot-bookmarklet.confd" scibot-bookmarklet
	distutils-r1_src_install
}

pkg_postinst() {
	ewarn "In order to run scibot you need to set the hypothes.is"
	ewarn "group, user, and api token in /etc/conf.d/scibot-bookmarklet"
}
