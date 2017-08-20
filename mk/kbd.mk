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

kbd-full: share/kbd/be-latin1.map share/kbd/fr-latin1.map share/kbd/dvorak.map \
share/kbd/dvorak-r.map share/kbd/dvorak-l.map share/kbd/br-abnt2.map \
share/kbd/cf.map share/kbd/cz-lat2.map share/kbd/dk-latin1.map share/kbd/es.map \
share/kbd/fi.map share/kbd/it.map share/kbd/is-latin1.map share/kbd/jp106.map \
share/kbd/nl2.map share/kbd/no-latin1.map share/kbd/pl2.map \
share/kbd/pt-latin1.map share/kbd/ru1.map share/kbd/se-lat6.map \
share/kbd/tr_q-latin5.map share/kbd/trq.map share/kbd/uk.map \
share/kbd/us-acentos.map share/kbd/us.map share/kbd/croat.map \
share/kbd/de_CH-latin1.map share/kbd/de-latin1.map \
share/kbd/de-latin1-nodeadkeys.map share/kbd/fr_CH-latin1.map share/kbd/hu.map \
share/kbd/sg-latin1.map share/kbd/slovene.map
