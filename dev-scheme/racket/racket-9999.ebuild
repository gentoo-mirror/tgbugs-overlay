# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit pax-utils

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/racket/${PN}.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="minimal? ( http://download.racket-lang.org/installers/${PV}/${PN}-minimal-${PV}-src-builtpkgs.tgz ) !minimal? ( http://download.racket-lang.org/installers/${PV}/${P}-src-builtpkgs.tgz )"
	KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"
fi

DESCRIPTION="General purpose, multi-paradigm Lisp-Scheme programming language"
HOMEPAGE="https://racket-lang.org/"
LICENSE="MIT Apache-2.0"
SLOT="0/9999"
IUSE="bc cgc +cs doc +futures +jit minimal +places +readline +threads +X"
REQUIRED_USE="futures? ( jit ) || ( bc cgc cs )"

RDEPEND="
	app-eselect/eselect-racket
	dev-db/sqlite:3
	media-libs/libpng:0
	x11-libs/cairo[X?]
	x11-libs/pango[X?]
	virtual/libffi
	virtual/jpeg:0
	readline? ( dev-libs/libedit )
	X? ( x11-libs/gtk+[X?] )"
RDEPEND="${RDEPEND} !dev-tex/slatex"

DEPEND="${RDEPEND}"

if [[ ${PV} == "9999" ]]; then
	S="${WORKDIR}/${P}/${PN}/src"
else
	S="${WORKDIR}/${P}/src"
fi

src_prepare() {
	rm -r bc/foreign/libffi || die 'failed to remove bundled libffi'
	default
	eapply_user
}

src_configure() {
	# According to vapier, we should use the bundled libtool
	# such that we don't preclude cross-compile. Thus don't use
	# --enable-lt=/usr/bin/libtool
	# FIXME boothelp only if 9999
	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--collectsdir="${EPREFIX}"/usr/share/racket/collects \
		--pkgsdir="${EPREFIX}"/usr/share/racket/pkgs \
		--enable-shared \
		--enable-float \
		--enable-libffi \
		--enable-foreign \
		--disable-libs \
		--disable-strip \
		--enable-useprefix \
		--disable-bcdefault \
		--disable-csdefault \
		$(use_enable bc) \
		$(use_enable cs) \
		$(if [[ ${PV} == "9999" ]]; then use_enable cs boothelp; else echo ""; fi) \
		$(use_enable X gracket) \
		$(use_enable doc docs) \
		$(use_enable jit) \
		$(use_enable places) \
		$(use_enable futures) \
		$(use_enable threads pthread)
}

src_compile() {
	if use jit; then
		# When the JIT is enabled, a few binaries need to be pax-marked
		# on hardened systems (bug 613634). The trick is to pax-mark
		# them before they're used later in the build system. The
		# following order for racketcgc and racket3m was determined by
		# digging through the Makefile in src/racket to find out which
		# targets would build those binaries but not use them.
		pushd bc
		emake cgc-core
		pax-mark m .libs/racketcgc
		pushd gc2
		emake all
		popd
		pax-mark m .libs/racket3m
		popd
	fi

	if use cgc; then
		emake cgc
	fi

	#if use bc || { [[ "${PV}" == "9999" ]] && use cs }; then  # not sure if need or if boothelp config enables
	if use bc; then
		emake bc
	fi

	if use cs; then
		emake cs
	fi
}

src_install() {

	local PATH_CS="${PORTAGE_BUILDDIR}/cs"
	local PATH_BC="${PORTAGE_BUILDDIR}/bc"
	local PATH_CGC="${PORTAGE_BUILDDIR}/cgc"

	# install
	if use cs; then
		emake DESTDIR="${PATH_CS}/image/" install-cs || die "died running make install, $FUNCNAME"
	fi

	if use bc; then
		emake DESTDIR="${PATH_BC}/image/" install-bc || die "died running make install, $FUNCNAME"
	fi

	if use cgc; then
		emake DESTDIR="${PATH_CGC}/image/" install-cgc || die "died running make install, $FUNCNAME"
	fi

	# copy to image sequentially
	if use cgc; then
		cp -au "${PATH_CGC}/image/"* "${D}" || die "copying cgc failed"
		rm -r "${PATH_CGC}"
	fi

	if use bc; then
		cp -au "${PATH_BC}/image/"* "${D}" || die "copying bc failed"
		rm -r "${PATH_BC}"
	fi

	if use cs; then
		cp -au "${PATH_CS}/image/"* "${D}" || die "copying cs failed"
		rm -r "${PATH_CS}"
	fi

	if use jit; then
		# The final binaries need to be pax-marked, too, if you want to
		# actually use them. The src_compile marking get lost somewhere
		# in the install process.
		for f in mred mzscheme racket; do
			pax-mark m "${D}/usr/bin/${f}"
		done

		use X && pax-mark m "${D}/usr/$(get_libdir)/racket/gracket"
	fi
	# raco needs decompressed files for packages doc installation bug 662424
	if use doc; then
		docompress -x /usr/share/doc/${PF}
	fi
	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
