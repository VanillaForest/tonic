export CROSS_COMPILE=
export CC=$(CROSS_COMPILE)gcc
export ARCH=$(shell $(CC) -dumpmachine|sed 's/-.*//'|sed 's/i.86/i386/')
export CPPFLAGS=-isystem $(CURDIR)/include
export CFLAGS=-g -O2
export LDFLAGS=-L$(CURDIR)/lib -Wl,--dynamic-linker=/lib/libc.so
export THREADS=4

default: bin/busybox bin/tinysshd

clean-src:
	find src -maxdepth 2 -name Makefile -exec dirname {} \;|while read name; do make -C $$name clean; done

clean: clean-src
	rm -rf bin etc lib include share boot proc sys dev

chroot:
	unshare -U -r -p -f -m --propagation slave -u -i assets/ms-namespace-init.sh /bin/sh

include mk/*.mk
