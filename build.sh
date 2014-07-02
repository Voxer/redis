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


case "$(uname)" in
	SunOS)
		prefix=/opt/local
		make=make
		checksum=sha256sum
		;;
	Linux)
		prefix=/usr/local
		make=make
		checksum=sha256sum
		;;
	FreeBSD)
		pkg install -y autoconf
		prefix=/usr/local
		make=gmake
		checksum=sha256
		;;
esac
configure_opts+=(--prefix=$prefix)


echo '> cleaning up previous builds'
$make clean > /dev/null

echo '> prepping jemalloc'
if [[ ! -d deps/jemalloc/.git ]]; then
	rm -rf deps/jemalloc
	git clone -b Voxer-Solaris git@github.com:georgekola/jemalloc.git deps/jemalloc
fi
(
cd deps/jemalloc &&
./autogen.sh --with-jemalloc-prefix=je_ > /dev/null &&
$make > /dev/null
) || exit 1

echo '> running make'
mkdir -p "$out"
$make PREFIX="$out$prefix" install MALLOC=jemalloc V=1 > /dev/null || exit 1

echo "> redis built in $SECONDS seconds, saved to $out"
echo
cd "$out$prefix/bin" && $checksum "${binaries[@]}"
