LVM=2.02.168

src/lvm/configure:
	mk/tarball lvm https://mirrors.kernel.org/sourceware/lvm2/releases/LVM2.$(LVM).tgz
	for p in assets/lvm2-*.patch; do (cd src/lvm; patch -p1 < "$(CURDIR)/$$p") done

src/lvm/Makefile: src/lvm/configure
	cd src/lvm && \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes \
	CFLAGS="$(CPPFLAGS) $(CFLAGS)" \
	./configure \
		--host=$(shell $(CC) -dumpmachine) \
		--prefix= \
		--sysconfdir=/etc \
		--libdir=/lib \
		--sbindir=/bin \
		--localstatedir=/var \
		--disable-nls \
		--disable-readline \
		--enable-pkgconfig \
		--enable-applib \
		--with-thin=internal \
		--enable-cmdlib

bin/lvm: src/lvm/Makefile
	make -C src/lvm V=1 CFLAGS="$(CPPFLAGS) $(CFLAGS)"
	make -C src/lvm V=1 CFLAGS="$(CPPFLAGS) $(CFLAGS)" DESTDIR=$(CURDIR) install
