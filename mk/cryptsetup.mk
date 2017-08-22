CRYPTSETUP=1.7.4

sources: src/cryptsetup/configure

src/cryptsetup/configure:
	assets/tarball.sh cryptsetup https://www.kernel.org/pub/linux/utils/cryptsetup/v$(shell echo "$(CRYPTSETUP)"|cut '-d.' -f1-2)/cryptsetup-$(CRYPTSETUP).tar.xz

src/cryptsetup/Makefile: config.mk src/cryptsetup/configure lib/libdevmapper.so lib/libpopt.so lib/libnettle.so include/linux/fcntl.h lib/libuuid.a
	cd src/cryptsetup && ./configure \
		--host=$(shell $(CC) -dumpmachine) \
		--with-sysroot=$(CURDIR) \
		--prefix= \
		--sysconfdir=/etc \
		--libdir=/lib \
		--sbindir=/bin \
		--disable-nls \
		--with-crypto_backend=nettle

bin/cryptsetup: src/cryptsetup/Makefile
	make -C src/cryptsetup -j$(THREADS) V=1
	make -C src/cryptsetup DESTDIR="$(CURDIR)" install
