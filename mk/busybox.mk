BUSYBOX=1.27.1

src/busybox/Makefile:
	assets/tarball.sh busybox https://busybox.net/downloads/busybox-$(BUSYBOX).tar.bz2

src/busybox/.config: src/busybox/Makefile
	make -j$(THREADS) -C src/busybox defconfig

bin/busybox: src/busybox/.config src/busybox/Makefile include/linux/fcntl.h lib/libc.so
	make -j$(THREADS) -C src/busybox V=1 \
		CC="$(CC)" \
		CONFIG_CROSS_COMPILER_PREFIX="$(CROSS_COMPILE)" \
		CONFIG_SYSROOT="$(CURDIR)" \
		CONFIG_EXTRA_CFLAGS="$(CFLAGS)" \
		CONFIG_EXTRA_LDFLAGS="$(LDFLAGS)" \
		all busybox.links
	install -D src/busybox/busybox bin/busybox
	install -D src/busybox/docs/busybox.1 share/man/man1/busybox.1
	for applet in `cat src/busybox/busybox.links|sed 's|^.*/||'`; do ln -s busybox bin/$$applet || true; done
	mkdir -p etc
	for sh in ash hush sh; do grep -qx /bin/$$sh etc/shells || echo /bin/$$sh >> etc/shells; done
