KBD_VER=2.0.4

src/kbd/configure:
	assets/tarball.sh kbd http://cdn.kernel.org/pub/linux/utils/kbd/kbd-$(KBD_VER).tar.xz
	sed -i 's/progname/prgname/g' src/kbd/src/loadkeys.c

src/kbd/src/config.h: src/kbd/configure assets/kbd_config.h
	cp -f assets/kbd_config.h src/kbd/src/config.h

src/kbd/src/libkeymap/config.h: src/kbd/configure src/kbd/configure
	ln -sf ../config.h src/kbd/src/libkeymap/config.h

src/kbd/loadkeys: src/kbd/src/config.h src/kbd/src/libkeymap/config.h
	cd src/kbd && $(HOSTCC) -Isrc -Isrc/libkeymap \
		src/libkeymap/common.c \
		src/libkeymap/findfile.c \
		src/libkeymap/array.c \
		src/libkeymap/parser.c \
		src/libkeymap/analyze.c \
		src/libkeymap/func.c \
		src/libkeymap/kmap.c \
		src/libkeymap/diacr.c \
		src/libkeymap/ksyms.c \
		src/libkeymap/dump.c \
		src/libkeymap/loadkeys.c \
		src/libkeymap/modifiers.c \
		src/kbd_error.c src/getfd.c \
		src/loadkeys.c -o loadkeys

share/kbd/%.map: src/kbd/loadkeys
	mkdir -p $(CURDIR)/share/kbd
	k=$$(basename $@) ; \
	k=$${k%.map} ; \
	src/kbd/loadkeys -b -q $$(find src/kbd/data/keymaps/i386 -name $$k.map) > $(CURDIR)/share/kbd/$$k.map

ifneq ($(KBDMAP),)
default: share/kbd/$(KBDMAP).map
endif
