LIBZ_VER=1.2.8.2015.12.26

src/libz/configure:
	assets/tarball.sh libz https://sortix.org/libz/release/libz-$(LIBZ_VER).tar.gz

src/libz/Makefile: src/libz/configure lib/libc.so config.mk
	cd src/libz && ./configure \
		--prefix="" \
		--host=$(shell $(CC) -dumpmachine)

lib/libz.so: src/libz/Makefile
	make -C src/libz -j$(THREADS)
	make -C src/libz V=1 DESTDIR="$(CURDIR)" install

include/zlib.h: lib/libz.so
