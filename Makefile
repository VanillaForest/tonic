export CROSS_COMPILE=
export CC=$(CROSS_COMPILE)gcc
export ARCH=$(shell $(CC) -dumpmachine|sed 's/-.*//'|sed 's/i.86/i386/')

export CPPFLAGS=-isystem $(CURDIR)/include
export CFLAGS=-O3
export LDFLAGS=-L$(CURDIR)/lib

LINUX_VER=4.9.27
BUSYBOX_VER=1.26.2
MUSL_VER=1.1.16
SYSLINUX_VER=6.03
E2FSPROGS_VER=1.43.4
ZLIB_VER=1.2.11

LINUX_CFG=$(CURDIR)/assets/linux.kconfig
BUSYBOX_CFG=$(CURDIR)/assets/busybox.kconfig

default:
	echo $(ARCH)

clean:
	rm -rf bin etc lib include share boot proc sys dev
	find src -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

chroot:
	unshare -U -r -p -f -m --propagation slave -u -i assets/ms-namespace-init.sh /bin/sh

# === LINUX ===
src/linux-$(LINUX_VER).tar.xz:
	mkdir -p src
	cd src && wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(LINUX_VER).tar.xz

src/linux-$(LINUX_VER)/Makefile: src/linux-$(LINUX_VER).tar.xz
	cd src && tar -xmf linux-$(LINUX_VER).tar.xz

include/linux/fcntl.h: src/linux-$(LINUX_VER)/Makefile
	mkdir -p include
	make -C src/linux-$(LINUX_VER) ARCH="$(ARCH)" INSTALL_HDR_PATH="$(CURDIR)" headers_install

include/linux/%.h: include/linux/fcntl.h
	true

src/linux-$(LINUX_VER)/vmlinux: src/linux-$(LINUX_VER)/Makefile
	mkdir -p boot
	make -C src/linux-$(LINUX_VER) ARCH=$(ARCH) \
		KCONFIG_ALLCONFIG=$(LINUX_CFG) \
		allnoconfig
	make -j4 -C src/linux-$(LINUX_VER) ARCH=$(ARCH) \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		CC="$(CC)" CFLAGS="$(CFLAGS)" \
		KBUILD_BUILD_USER=root \
		KBUILD_BUILD_HOST=tonic

# Hint: this is intel-specific
boot/bzImage: src/linux-$(LINUX_VER)/vmlinux
	cp src/linux-$(LINUX_VER)/arch/x86/boot/bzImage boot/bzImage
	cp src/linux-$(LINUX_VER)/System.map boot/System.map
	cp src/linux-$(LINUX_VER)/.config boot/config

# === MUSL ===
src/musl-$(MUSL_VER).tar.gz:
	cd src && wget https://www.musl-libc.org/releases/musl-$(MUSL_VER).tar.gz

src/musl-$(MUSL_VER)/Makefile: src/musl-$(MUSL_VER).tar.gz
	cd src && tar -xmf musl-$(MUSL_VER).tar.gz

lib/libc.so: src/musl-$(MUSL_VER)/Makefile include/linux/fcntl.h
	mkdir -p lib
	cd src/musl-$(MUSL_VER) && ./configure --prefix="" --host="$(CROSS_COMPILE)" --syslibdir="/lib"
	make -C src/musl-$(MUSL_VER)
	make -C src/musl-$(MUSL_VER) DESTDIR="$(CURDIR)" install

# === BUSYBOX ===
src/busybox-$(BUSYBOX_VER).tar.bz2:
	mkdir -p src
	cd src && wget https://busybox.net/downloads/busybox-$(BUSYBOX_VER).tar.bz2

src/busybox-$(BUSYBOX_VER)/Makefile: src/busybox-$(BUSYBOX_VER).tar.bz2
	cd src && tar -xmf busybox-$(BUSYBOX_VER).tar.bz2

bin/busybox: src/busybox-$(BUSYBOX_VER)/Makefile include/linux/fcntl.h
	make -C src/busybox-$(BUSYBOX_VER) KCONFIG_ALLCONFIG=$(BUSYBOX_CFG) allnoconfig
	make -C src/busybox-$(BUSYBOX_VER) V=1 CC="$(CC)" CFLAGS="$(CPPFLAGS) $(CFLAGS)" LDFLAGS="$(LDFLAGS)" all
	make -C src/busybox-$(BUSYBOX_VER) busybox.links
	mkdir -p bin
	cp src/busybox-$(BUSYBOX_VER)/busybox bin/busybox
	for i in $$(cat src/busybox-$(BUSYBOX_VER)/busybox.links|sed 's|^.*/||'); do ln -s busybox bin/$$i; done||true

#= == E2FSPROGS ===
src/e2fsprogs-$(E2FSPROGS_VER).tar.xz:
	cd src && wget https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.xz

src/e2fsprogs-$(E2FSPROGS_VER)/configure: src/e2fsprogs-$(E2FSPROGS_VER).tar.xz
	cd src && tar -xmf e2fsprogs-$(E2FSPROGS_VER).tar.xz
	cd src/e2fsprogs-$(E2FSPROGS_VER) && for i in misc/fsck.c misc/mke2fs.c e2fsck/unix.c;do sed -i 's@sbin@bin@g' $$i;done
	cd src/e2fsprogs-$(E2FSPROGS_VER) && patch -t -p0 < $(CURDIR)/assets/e2fsprogs-missing-sys-stat.patch

bin/mke2fs: src/e2fsprogs-$(E2FSPROGS_VER)/configure lib/libc.so
	cd src/e2fsprogs-$(E2FSPROGS_VER) && ./configure --prefix="" --host=$(shell echo $(CROSS_COMPILE)|sed 's/-$$//') \
		--sbindir=/bin --disable-nls --enable-symlink-install --enable-relative-symlinks e2fsprogs_cv_struct_st_flags=no
	make V=1 -C src/e2fsprogs-$(E2FSPROGS_VER)
	make -C src/e2fsprogs-$(E2FSPROGS_VER) DESTDIR="$(CURDIR)" install
	make -C src/e2fsprogs-$(E2FSPROGS_VER) DESTDIR="$(CURDIR)" install-libs

lib/libuuid.a: bin/mke2fs
	true

# === SYSLINUX ===
src/syslinux-$(SYSLINUX_VER).tar.xz:
	cd src && wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-$(SYSLINUX_VER).tar.xz

src/syslinux-$(SYSLINUX_VER)/Makefile: src/syslinux-$(SYSLINUX_VER).tar.xz
	cd src && tar -xmf syslinux-$(SYSLINUX_VER).tar.xz
	cd src/syslinux-$(SYSLINUX_VER);\
	cp Makefile Makefile.orig;\
	sed -i 's,/sbin,/bin,' syslinux.spec mk/syslinux.mk;\
	sed '/DIRS/ s/\(utils\|dosutil\)//g' -i Makefile;\
	sed '/DIAGDIR/d' -i Makefile ;\
	sed 's:[a-z0-9]*/[a-z0-9]*\.\(exe\|sys\|com\)::g' -i Makefile;\
	sed 's:core/isolinux-debug.bin::g' -i Makefile;\
	sed 's:gpxe/[^ ]*::g' -i Makefile;\
	sed 's|[a-z]*_c.bin||' -i mbr/Makefile;\
	sed -i 's,#include <getkey.h>,#include "include/getkey.h",' com32/libutil/keyname.c;\
	sed -i 's,#include <libutil.h>,#include "include/libutil.h",' com32/libutil/keyname.c;\
	sed -i 's,#include "sha1.h",#include "include/sha1.h",' com32/libutil/sha1hash.c;\
	sed -i 's,#include <base64.h>,#include "include/base64.h",' com32/libutil/unbase64.c;\
	sed -i 's,#include <md5.h>,#include "include/md5.h",' com32/libutil/md5.c;\
	sed -i 's,#include <md5.h>,#include "include/md5.h",' com32/libutil/crypt-md5.c;\
	sed -i 's,#include <minmax.h>,#include "include/minmax.h",' com32/libutil/sha256crypt.c;\
	sed -i 's,#include "xcrypt.h",#include "include/xcrypt.h",' com32/libutil/sha256crypt.c;\
	sed -i 's,#include <minmax.h>,#include "include/minmax.h",' com32/libutil/sha512crypt.c;\
	sed -i 's,#include "xcrypt.h",#include "include/xcrypt.h",' com32/libutil/sha512crypt.c;\
	sed -i 's,#include <base64.h>,#include "include/base64.h",' com32/libutil/base64.c

bin/syslinux: src/syslinux-$(SYSLINUX_VER)/Makefile lib/libuuid.a lib/libc.so
	make -C src/syslinux-$(SYSLINUX_VER) PREFIX="" BINDIR='/bin' SBINDIR='/bin' \
		LIBDIR='/lib' DATADIR='/share' MANDIR='/share/man' INCDIR='/include' \
		CC="$(CC) -L$(CURDIR)/lib -isystem $(CURDIR)/include" OPTFLAGS="$(CFLAGS)" \
		AUXDIR="/share/syslinux" INSTALLROOT="$(CURDIR)" bios installer
	make -C src/syslinux-$(SYSLINUX_VER) PREFIX="" BINDIR='/bin' SBINDIR='/bin' \
		LIBDIR='/lib' DATADIR='/share' MANDIR='/share/man' INCDIR='/include' \
		CC="$(CC) -L$(CURDIR)/lib -isystem $(CURDIR)/include" OPTFLAGS="$(CFLAGS)" \
		AUXDIR="/share/syslinux" INSTALLROOT="$(CURDIR)" bios install

bin/extlinux: bin/syslinux
share/syslinux/%.bin: bin/syslinux
	true

# === ZLIB ===
src/zlib-$(ZLIB_VER).tar.xz:
	mkdir -p src
	cd src && wget http://zlib.net/zlib-$(ZLIB_VER).tar.xz

src/zlib-$(ZLIB_VER)/configure: src/zlib-$(ZLIB_VER).tar.xz
	cd src && tar -xmf zlib-$(ZLIB_VER).tar.xz

lib/libz.so: src/zlib-$(ZLIB_VER)/configure lib/libc.so
	cd src/zlib-$(ZLIB_VER) && ./configure --prefix=""
	make -C src/zlib-$(ZLIB_VER)
	make -C src/zlib-$(ZLIB_VER) DESTDIR="$(CURDIR)" install
