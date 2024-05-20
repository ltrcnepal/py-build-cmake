#!/usr/bin/env bash

# This script downloads cross-compilation toolchains for a range of popular
# architectures (x86-64, ARMv6, ARMv7, ARMv8-64), as well as binaries of all
# current versions of CPython and PyPy.
# These can then be used to cross-compile packages using py-build-cmake

cd "$( dirname "${BASH_SOURCE[0]}" )"/..

triples=(x86_64-bionic-linux-gnu armv6-rpi-linux-gnueabihf armv7-neon-linux-gnueabihf aarch64-rpi3-linux-gnu)
gcc_version="14"
toolchain_version="0.1.0"
python_dev_version="0.0.2"
toolchain_folder="$PWD/toolchains"

set -ex

mkdir -p "$toolchain_folder/x-tools"
for triple in ${triples[@]}; do
    chmod u+w "$toolchain_folder/x-tools"
    wget "https://github.com/tttapa/toolchains/releases/download/$toolchain_version/x-tools-$triple-gcc$gcc_version.tar.xz" -O- | tar xJ -C "$toolchain_folder"
    chmod u+w "$toolchain_folder/x-tools/$triple"
    wget "https://github.com/tttapa/python-dev/releases/download/$python_dev_version/python-dev-$triple.tar.xz" -O- | tar xJ -C "$toolchain_folder"
done

# To delete the toolchains again, use
#   chmod -R u+w toolchains && rm -rf toolchains