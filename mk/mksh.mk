MKSH=R55

src/mksh/Build.sh:
	mk/tarball mksh https://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-$(MKSH).tgz

bin/mksh: src/mksh/Build.sh lib/libc.so
	cd src/mksh && sh ./Build.sh -r
	install -D src/mksh/mksh bin/mksh
	install -D src/mksh/mksh.1 share/man/man1/mksh.1
	mkdir -p etc
	grep -qx '/bin/mksh' etc/shells || echo '/bin/mksh' >> etc/shells
