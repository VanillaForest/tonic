MUSL_VER=1.1.16

src/musl/Makefile:
	mk/tarball musl https://www.musl-libc.org/releases/musl-$(MUSL_VER).tar.gz

src/musl/config.mak: src/musl/Makefile
	cd src/musl && ./configure --prefix="" --host="$(CROSS_COMPILE)" --syslibdir="/lib" --disable-wrapper

lib/libc.so: src/musl/config.mak src/musl/Makefile
	mkdir -p lib
	make -j$(THREADS) -C src/musl
	make -j$(THREADS) -C src/musl DESTDIR="$(CURDIR)" install


