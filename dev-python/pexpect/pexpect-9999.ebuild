# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} pypy pypy3 )
PYTHON_REQ_USE="threads(+)"

inherit git-r3 distutils-r1

DESCRIPTION="Python module for spawning child apps and responding to expected patterns"
HOMEPAGE="https://pexpect.readthedocs.io/ https://pypi.org/project/pexpect/ https://github.com/pexpect/pexpect/"
EGIT_REPO_URI="https://github.com/pexpect/pexpect.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="doc examples test"

RDEPEND=">=dev-python/ptyprocess-0.5[${PYTHON_USEDEP}]"
DEPEND="
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )"

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	py.test tests || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/_build/html/. )
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
	distutils-r1_python_install_all
}
