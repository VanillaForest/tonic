etc/shells: bin
	for sh in $(ETC_SHELLS); do \
		[ -x $(CURDIR)$$sh ] && echo $$sh ;\
	done > etc/shells
