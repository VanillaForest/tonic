MKSH=R56
ETC_SHELLS += /bin/mksh

sources: src/mksh/Build.sh

src/mksh/Build.sh:
	assets/tarball.sh mksh https://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-$(MKSH).tgz

bin/mksh: src/mksh/Build.sh lib/libc.so
	cd src/mksh && sh ./Build.sh -r
	install -D src/mksh/mksh bin/mksh
	install -D src/mksh/mksh.1 share/man/man1/mksh.1
