# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( pypy3 python3_{10..11} )

PYPI_NO_NORMALIZE=1
inherit distutils-r1 pypi

DESCRIPTION="Framework for fast, easy, and documented API development with Flask"
HOMEPAGE="https://github.com/python-restx/flask-restx"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dev doc test"
RESTRICT="
	!test? ( test )
"

DEPEND=""
RDEPEND="${DEPEND}
	>=dev-python/aniso8601-0.82
	dev-python/jsonschema
	>=dev-python/flask-0.8
	<dev-python/flask-3.0.0
	dev-python/pytz
	>=dev-python/six-1.3.0
	dev-python/werkzeug
	dev? (
		dev-python/black
		dev-python/tox
	)
	doc? (
		=dev-python/alabaster-0.7.12
		=dev-python/sphinx-5.3.0
		=dev-python/sphinx-issues-3.0.1
	)
	test? (
		dev-python/blinker
		=dev-python/faker-2.0.0
		=dev-python/mock-3.0.5
		=dev-python/invoke-1.3.0
		=dev-python/pytest-7.0.1
		=dev-python/pytest-benchmark-3.4.1
		=dev-python/pytest-cov-4.0.0
		=dev-python/pytest-flask-1.2.0
		=dev-python/pytest-mock-3.6.1
		=dev-python/pytest-profiling-1.7.0
		=dev-python/invoke-1.7.3
		=dev-python/twine-3.8.0
		dev-python/tzlocal
	)
"
