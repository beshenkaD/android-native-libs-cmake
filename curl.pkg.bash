#!/bin/bash

NAME="curl"
REPO="https://github.com/curl/curl.git"
REPO_NAME="curl"
BRANCH="master"
DEPS=("openssl")

build() {
    local arch=$1
    local prefix=$2
    
    if [[ "$arch" = "aarch64" ]]; then
        TARGET="aarch64-linux-android"
        export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
        export AR=$TOOLCHAIN/bin/llvm-ar
        export AS=$TOOLCHAIN/bin/llvm-as
        export CC=$TOOLCHAIN/bin/${TARGET}${MIN_SDK_VERSION}-clang
        export CXX=$TOOLCHAIN/bin/${TARGET}${MIN_SDK_VERSION}-clang++
        export LD=$TOOLCHAIN/bin/ld
        export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
        export STRIP=$TOOLCHAIN/bin/llvm-strip
        
        autoreconf -fi
        ./configure --host ${TARGET} \
        --target ${TARGET} \
        --with-pic \
        --disable-shared \
        --prefix=$prefix/$REPO_NAME/$arch \
        --with-openssl=$prefix/openssl/$arch/
        make -j$(nproc)
        make install
        make clean
    fi

    if [[ "$arch" = "x86_64" ]]; then
        TARGET="x86_64-linux-android"
        export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
        export AR=$TOOLCHAIN/bin/llvm-ar
        export AS=$TOOLCHAIN/bin/llvm-as
        export CC=$TOOLCHAIN/bin/${TARGET}${MIN_SDK_VERSION}-clang
        export CXX=$TOOLCHAIN/bin/${TARGET}${MIN_SDK_VERSION}-clang++
        export LD=$TOOLCHAIN/bin/ld
        export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
        export STRIP=$TOOLCHAIN/bin/llvm-strip
        
        autoreconf -fi
        ./configure --host ${TARGET} \
        --target ${TARGET} \
        --with-pic \
        --disable-shared \
        --prefix=$prefix/$REPO_NAME/$arch \
        --with-openssl=$prefix/openssl/$arch/
        make -j$(nproc)
        make install
        make clean
    fi
}
