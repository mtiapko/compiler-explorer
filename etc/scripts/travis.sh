#!/bin/bash

set -ex

OPT=$(pwd)/out/compilers
rm -rf ${OPT}
mkdir -p ${OPT}
mkdir -p ${OPT}/tmp

fetch() {
    curl -v ${http_proxy:+--proxy $http_proxy} -L "$*"
}

get_ghc() {
    local VER=$1
    local DIR=ghc-$VER

	pushd ${OPT}/tmp
	fetch https://downloads.haskell.org/~ghc/${VER}/ghc-${VER}-x86_64-deb8-linux.tar.xz | tar Jxf -
	cd /tmp/ghc-${VER}
	./configure --prefix=${OPT}/ghc
	make install
	popd
    rm -rf ${OPT}/tmp/ghc-${VER}
}

get_gdc() {
    vers=$1
    build=$2
    mkdir ${OPT}/gdc
    pushd ${OPT}/gdc
    fetch ftp://ftp.gdcproject.org/binaries/${vers}/x86_64-linux-gnu/gdc-${vers}+${build}.tar.xz | tar Jxf -
    popd
}

do_rust_install() {
    local DIR=$1
    pushd ${OPT}/tmp
    fetch http://static.rust-lang.org/dist/${DIR}.tar.gz | tar zxvf -
    cd ${DIR}
    ./install.sh --prefix=${OPT}/rust --without=rust-docs
    popd
    rm -rf ${OPT}/tmp/${DIR}
}

install_new_rust() {
    local NAME=$1
    
    do_rust_install rust-${NAME}-x86_64-unknown-linux-gnu
}

get_ghc 8.0.2
get_gdc 5.2.0 2.066.1
install_new_rust nightly
