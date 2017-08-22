MUSL_VER=1.1.16

sources: src/musl/Makefile

src/musl/Makefile:
	assets/tarball.sh musl https://www.musl-libc.org/releases/musl-$(MUSL_VER).tar.gz

src/musl/config.mak: config.mk src/musl/Makefile
	cd src/musl && ./configure \
		--prefix=""
		--host="$(CROSS_COMPILE)"
		--syslibdir="/lib"
		--disable-wrapper

lib/libc.so: src/musl/config.mak src/musl/Makefile
	mkdir -p lib
	make -C src/musl -j$(THREADS)
	make -C src/musl DESTDIR="$(CURDIR)" install


