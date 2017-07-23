export
include config.mk

ARCH=$(shell $(CC) -dumpmachine|sed 's/-.*//'|sed 's/i.86/i386/')

# This is where the compiler looks for include files
CPPFLAGS += -isystem $(CURDIR)/include

# This is where the linker looks for libraries
# Because of some dumb build systems you need it twice
LDFLAGS += -L$(CURDIR)/lib
LDFLAGS += -Wl,-rpath-link=$(CURDIR)/lib

# This is the libc path encoded in each binary
LDFLAGS += -Wl,--dynamic-linker=/lib/libc.so

default: bin/busybox bin/tinysshd

showconf:
	@echo CC=$(CC)
	@echo CPPFLAGS=$(CPPFLAGS)
	@echo CFLAGS=$(CFLAGS)
	@echo LDFLAGS=$(LDFLAGS)

clean-src:
	find src -maxdepth 2 -name Makefile -exec dirname {} \;|while read name; do make -C $$name clean; done

clean: clean-src
	rm -rf bin etc lib include share boot proc sys dev

chroot:
	unshare -U -r -p -f -m --propagation slave -u -i assets/ms-namespace-init.sh /bin/sh

include mk/*.mk
