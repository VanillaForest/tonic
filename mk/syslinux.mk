src/syslinux/Makefile:
	assets/tarball.sh syslinux https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz
	cd src/syslinux && $(CURDIR)/assets/patch-syslinux.sh

syslinux: src/syslinux/Makefile lib/libc.so include/linux/fcntl.h include/uuid/uuid.h
	ARGS="V=1 BINDIR='/bin' SBINDIR='/bin' LIBDIR='/lib' DATADIR='/share' MANDIR='/share/man' INCDIR='/include'" ;\
	make -C src/syslinux $$ARGS CC="$(CC)" OPTFLAGS="$(CPPFLAGS) $(CFLAGS) $(LDFLAGS)" \
		AUXDIR="/share/syslinux" INSTALLROOT="$(CURDIR)" bios installer ;\
	make -C src/syslinux $$ARGS CC="$(CC)" OPTFLAGS="$(CPPFLAGS) $(CFLAGS) $(LDFLAGS)" \
		AUXDIR="/share/syslinux" INSTALLROOT="$(CURDIR)" bios install ;\
