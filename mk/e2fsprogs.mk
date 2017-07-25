E2FSPROGS=1.43.4

src/e2fsprogs/configure:
	assets/tarball.sh e2fsprogs https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$(E2FSPROGS)/e2fsprogs-$(E2FSPROGS).tar.xz
	cd src/e2fsprogs && for i in misc/fsck.c misc/mke2fs.c e2fsck/unix.c;do sed -i 's@sbin@bin@g' $$i;done
	cd src/e2fsprogs && patch -t -p0 < $(CURDIR)/assets/e2fsprogs-missing-sys-stat.patch

src/e2fsprogs/Makefile: config.mk src/e2fsprogs/configure lib/libc.so include/linux/fcntl.h
	cd src/e2fsprogs && ./configure \
		--prefix="" \
		--host=$(shell $(CC) -dumpmachine) \
		--sbindir=/bin \
		--disable-nls \
		--enable-symlink-install \
		--enable-relative-symlinks \
		--disable-debugfs \
		--disable-tls \
		--disable-uuidd \
		--disable-mmp \
		--disable-tdb \
		--disable-bmap-stats \
		--disable-threads \
		--disable-rpath \
		--disable-fuse2fs \
		e2fsprogs_cv_struct_st_flags=no

bin/mke2fs: src/e2fsprogs/Makefile
	make -C src/e2fsprogs -j$(THREADS) V=1
	make -C src/e2fsprogs DESTDIR="$(CURDIR)" install
	make -C src/e2fsprogs DESTDIR="$(CURDIR)" install-libs

lib/libuuid.a: bin/mke2fs
	true
