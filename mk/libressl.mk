sources: src/libressl/configure

src/libressl/configure:
	assets/tarball.sh libressl https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.6.0.tar.gz

src/libressl/Makefile: src/libressl/configure lib/libc.so include/linux/fcntl.h
	cd src/libressl && ./configure \
		--prefix="" \
		--host=$(shell $(CC) -dumpmachine) \
		--with-sysroot="$(CURDIR)"

bin/openssl: src/libressl/Makefile
	make -C src/libressl -j$(THREADS) V=1
	make -C src/libressl DESTDIR="$(CURDIR)" install

lib/libcrypto.a \
lib/libssl.a \
lib/libtls.a: bin/openssl
