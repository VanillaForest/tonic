#!/bin/sh
# Downloads the tarball given in $1 and extracts it to ~/src
set -e
set -x

url="$2"
name="$(basename "$url")"
dir="$PWD/src/$1"

mkdir -p "$PWD/src"
! [ -d "$dir" ]

if [ -f "$url" ]; then
	tarball="$url"
elif [ -f "$HOME/.cache/tarballs/$name" ]; then
	tarball="$HOME/.cache/tarballs/$name"
else
	(
		mkdir -p "$HOME/.cache/tarballs"
		cd "$HOME/.cache/tarballs"
		curl "$url" > "$name" || exit 1
	)
	tarball="$HOME/.cache/tarballs/$name"
fi

extractdir="$(mktemp -d)"
cd "$extractdir"
tar -xf "$tarball"
while [ "$(ls|wc -l)" = 1 ]; do cd *; done
mv -T "$PWD" "$dir" || echo "Try 'rm -rf ~/src/$dir'"
rm -rf "$extractdir"
