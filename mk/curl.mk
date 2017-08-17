src/curl/configure:
	assets/tarball.sh curl https://curl.haxx.se/download/curl-7.55.1.tar.xz

src/curl/Makefile: src/curl/configure
	LIBS="-lssl -lcrypto -lz" \
	cd src/curl && ./configure \
		--host=$(shell $(CC) -dumpmachine) \
		--with-sysroot=$(CURDIR) \
		--prefix="" \
		--with-ssl \
		--enable-ipv6 \
		--without-librtmp \
		--with-ca-path=/etc/ssl/certs \
		--with-random=/dev/urandom
	sed -i -e '/SUBDIRS/s:scripts::' src/curl/Makefile

bin/curl: src/curl/Makefile lib/libcrypto.a lib/libz.so
	make -C src/curl -j$(THREADS) V=1
	make -C src/curl DESTDIR="$(CURDIR)" install

lib/libcurl.a: bin/curl
