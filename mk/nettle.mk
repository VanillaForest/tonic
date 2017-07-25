NETTLE=3.3

src/nettle/configure:
	assets/tarball.sh nettle http://ftp.gnu.org/gnu/nettle/nettle-$(NETTLE).tar.gz

src/nettle/Makefile: config.mk src/nettle/configure lib/libc.so
	cd src/nettle && ./configure \
		--prefix="" \
		--host=$(shell $(CC) -dumpmachine) \
		--with-sysroot=$(CURDIR) \
		--disable-documentation \
		--sbindir=/bin

lib/libnettle.so: src/nettle/Makefile
	make -C src/nettle -j$(THREADS)
	make -C src/nettle DESTDIR="$(CURDIR)" install

