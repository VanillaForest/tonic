src/git/Makefile:
	assets/tarball.sh git https://www.kernel.org/pub/software/scm/git/git-2.9.5.tar.xz

bin/git: src/git/Makefile lib/libz.so lib/libcurl.a
	make -C src/git -j$(THREADS) V=1 \
		CC="$(CC)" \
		CPPFLAGS="$(CPPFLAGS)" \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(LDFLAGS)"
