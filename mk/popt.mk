POPT=1.16

sources: src/popt/configure

src/popt/configure:
	assets/tarball.sh popt http://rpm5.org/files/popt/popt-$(POPT).tar.gz

src/popt/Makefile: config.mk src/popt/configure lib/libc.so
	cd src/popt && ./configure \
		--prefix="" \
		--host=$(shell $(CC) -dumpmachine|sed 's/musl/gnu/')
	cd src/popt && for i in po ; do \
		printf 'all:\n\ttrue\ninstall:\n\ttrue\nclean:\n\ttrue\n' > "$$i"/Makefile; \
	done

lib/libpopt.so: src/popt/Makefile
	make -C src/popt -j$(THREADS) V=1
	make -C src/popt DESTDIR=$(CURDIR) install
