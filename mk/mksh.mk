MKSH=R55

src/mksh/Build.sh:
	mk/tarball mksh https://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-$(MKSH).tgz
	chmod +x src/mksh/Build.sh

bin/mksh: src/mksh/Build.sh lib/libc.so
	cd src/mksh && ./Build.sh
	install -D src/mksh/mksh bin/mksh
	install -D src/mksh/mksh.1 share/man/man1/mksh.1
	mkdir -p etc
	grep -q '/bin/mksh' etc/shells || echo '/bin/mksh' >> etc/shells
