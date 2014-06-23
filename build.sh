#!/usr/bin/env bash
#
# Voxer build script
#
# Author: Dave Eddy <dave@daveeddy.com>
# Date: 6/19/14

out=$1
arch=${2:-x64}

binaries=(redis-server redis-cli)

if [[ -z $out ]]; then
	echo 'error: out directory must be specified as the first argument'
	exit 1
fi

if [[ $arch != x64 ]]; then
	echo 'error: only x64 builds supported for redis' >&2
	exit 1
fi

echo '> cleaning up previous builds'
make clean > /dev/null

echo '> prepping jemalloc'
if [[ ! -d deps/jemalloc/.git ]]; then
	rm -rf deps/jemalloc
	git clone -b Voxer-Solaris git@github.com:georgekola/jemalloc.git deps/jemalloc
fi
(
cd deps/jemalloc &&
./autogen.sh --with-jemalloc-prefix=je_ > /dev/null &&
make > /dev/null
) || exit 1

echo '> running make'
make MALLOC=jemalloc V=1 > /dev/null || exit 1

echo "> copying files to $out"
mkdir -p "$out/bin"
for f in "${binaries[@]}"; do
	mv "src/$f" "$out/bin" || exit 1
done

echo "> redis built in $SECONDS seconds, saved to $out"
echo
cd "$out/bin" && sha256sum "${binaries[@]}"
