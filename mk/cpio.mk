boot/tonic.cpio.xz: bin/*
	mkdir -p boot
	find . | \
		grep -vf assets/cpio.exclude | \
		cpio -R root:root -H newc -o | \
		xz --check=crc32 --x86 --lzma2=dict=512KiB > boot/tonic.cpio.xz
