#!/bin/sh
mkdir -p proc
mount -t proc proc proc

mkdir -p dev
mount -t tmpfs tmpfs dev

mkdir -p dev/pts
mount -t devpts devpts dev/pts
ln -sfn pts/ptmx dev/ptmx

for i in random urandom null zero; do
	touch dev/$i
	mount --bind /dev/$i dev/$i
done

ln -sfn /proc/self/fd/0 dev/stdin
ln -sfn /proc/self/fd/1 dev/stdout
ln -sfn /proc/self/fd/2 dev/stderr

mount --bind . /

exec chroot . /bin/env -i "$@"
