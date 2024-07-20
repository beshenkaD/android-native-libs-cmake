#!/bin/bash
set -u
set -e
set -o nounset

if [ -z "${ANDROID_NDK+x}" ]; then
    echo "please export ANDROID_NDK"
    exit 1
fi

export BASE=$(realpath ${BASE:-$(pwd)})
export BASE_PREFIX=$BASE/prefix
export BASE_BUILD=$BASE/build
export ANDROID_NDK_HOME=$ANDROID_NDK
source ./config.bash

mkdir -p $BASE_BUILD
mkdir -p $BASE_PREFIX

check_dep() {
    test -f "$1" && return 0 || return 1
}

declare -a available_archs=("aarch64" "x86_64")
declare -a arch_array
declare -a packages

if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 --arch <arch1> <arch2> ... <archN> <package1> <package2> ... <packageN>"
    echo "Available arches are: ${available_archs[@]}"
    echo "Example: $0 --arch aarch64 x86_64 openssl curl"
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --arch)
            shift
            while [[ $# -gt 0 && "$1" != "--package" ]]; do
                arch="$1"
                if [[ " ${available_archs[@]} " =~ " $arch " ]]; then
                    arch_array+=("$arch")
                else
                    echo "Error: Invalid architecture: $arch"
                    exit 1
                fi
                shift
            done
        ;;
        --package)
            shift
            packages=("$@")
            break
        ;;
        *)
            echo "Error: Invalid argument: $1"
            exit 1
        ;;
    esac
done

if [[ ${#arch_array[@]} -eq 0 ]]; then
    echo "Error: Missing '--arch' argument."
    exit 1
fi

if [[ ${#packages[@]} -eq 0 ]]; then
    echo "Error: Missing '--package' argument."
    exit 1
fi

for arg in "${packages[@]}"; do
    export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
	cd $BASE
    source ./$arg.pkg.bash
    
    echo "Building $NAME..."
    
    cd $BASE_BUILD
    
    if [ -d $REPO_NAME ]; then
        echo "$REPO_NAME already here... skipping"
    else
        git clone --depth 1 \
        --recurse-submodules \
        --shallow-submodules \
        $REPO --branch $BRANCH
    fi
    cd $REPO_NAME
    
    echo "Building $NAME in $(realpath $PWD), deploying to $BASE_PREFIX/$REPO_NAME"

    for arch in "${arch_array[@]}"; do
        build $arch $BASE_PREFIX
    done
done
