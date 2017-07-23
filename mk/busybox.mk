BUSYBOX=1.27.1

src/busybox/Makefile:
	mk/tarball busybox https://busybox.net/downloads/busybox-$(BUSYBOX).tar.bz2

src/busybox/.config: src/busybox/Makefile
	make -j$(THREADS) -C src/busybox defconfig

bin/busybox: src/busybox/.config src/busybox/Makefile include/linux/fcntl.h lib/libc.so
	make -j$(THREADS) -C src/busybox V=1 CC="$(CC)" CFLAGS="$(CPPFLAGS) $(CFLAGS)" LDFLAGS="$(LDFLAGS)" DESTDIR="$(CURDIR)" all busybox.links
	install -D src/busybox/busybox bin/busybox
	for applet in `cat src/busybox/busybox.links|sed 's|^.*/||'`; do ln -s busybox bin/$$applet; done
