src/tinyssh/Makefile:
	cd src && git clone https://github.com/janmojzis/tinyssh.git

bin/tinysshd: src/tinyssh/Makefile lib/libc.so include/linux/fcntl.h
	echo "/bin" > src/tinyssh/conf-bin
	echo "/share/man" > src/tinyssh/conf-man
	cd src/tinyssh && ./make-tinysshcc.sh
	install -D src/tinyssh/build/bin/tinysshd bin/tinysshd
	install -D src/tinyssh/build/bin/tinysshd-makekey bin/tinysshd-makekey
	install -D src/tinyssh/build/bin/tinysshd-printkey bin/tinysshd-printkey
	install -D src/tinyssh/build/man/tinysshd.8 share/man/man8/tinysshd.8
	install -D src/tinyssh/build/man/tinysshd-makekey.1 share/man/man1/tinysshd-makekey.1
	install -D src/tinyssh/build/man/tinysshd-printkey.1 share/man/man1/tinysshd-printkey.1
