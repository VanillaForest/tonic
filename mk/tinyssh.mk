sources: src/tinyssh/Makefile

src/tinyssh/Makefile:
	assets/tarball.sh tinyssh https://mojzis.com/software/tinyssh/tinyssh-20161101.tar.gz

bin/tinysshd: src/tinyssh/Makefile lib/libc.so include/linux/fcntl.h
	echo "/bin" > src/tinyssh/conf-bin
	echo "/share/man" > src/tinyssh/conf-man
	cd src/tinyssh && ./make-tinysshcc.sh
	install -D src/tinyssh/build/bin/tinysshd bin/tinysshd
	install -D src/tinyssh/build/bin/tinysshd-makekey bin/tinysshd-makekey
	install -D src/tinyssh/build/bin/tinysshd-printkey bin/tinysshd-printkey
