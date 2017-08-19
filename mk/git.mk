src/git/Makefile:
	assets/tarball.sh git https://www.kernel.org/pub/software/scm/git/git-2.9.5.tar.xz

bin/git: src/git/Makefile lib/libz.so lib/libcurl.a
	make -C src/git -j$(THREADS) V=1 \
		CURL_LIBCURL="$(CURDIR)/lib/libcurl.a $(CURDIR)/lib/libssl.a $(CURDIR)/lib/libcrypto.a" \
		CC="$(CC)" \
		HOSTCC="$(HOSTCC)" \
		prefix="" \
		gitexecdir=/lib/git-core \
		NO_TCLTK=1 \
		NO_PYTHON=1 \
		NO_EXPAT=1 \
		NO_GETTEXT=1 \
		CPPFLAGS="$(CPPFLAGS)" \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(LDFLAGS)" \
		NO_REGEX=NeedsStartEnd \
		DESTDIR="$(CURDIR)" \
		all install
