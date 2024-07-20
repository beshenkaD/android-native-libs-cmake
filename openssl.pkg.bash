#!/bin/bash

NAME="OpenSSL"
REPO="https://github.com/openssl/openssl.git"
REPO_NAME="openssl"
BRANCH="OpenSSL_1_1_1-stable"
DEPS=()

build() {
    local arch=$1
    local prefix=$2

    if [[ "$arch" = "aarch64" ]]; then
        ./Configure no-shared android-arm64 --prefix=$prefix/$REPO_NAME/$arch
        make -j$(nproc)
        make -j$(nproc) install_sw
        make clean
    fi

    if [[ "$arch" = "armv7-a" ]]; then
        ./Configure no-shared android-arm --prefix=$prefix/$REPO_NAME/$arch
        make -j$(nproc)
        make -j$(nproc) install_sw
        make clean
    fi

    if [[ "$arch" = "x86_64" ]]; then
        ./Configure no-shared android-x86_64 --prefix=$prefix/$REPO_NAME/$arch
        make clean
        make depend
        make -j$(nproc) build_libs
        make -j$(nproc) install_sw
    fi
}