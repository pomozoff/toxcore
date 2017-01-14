#!/bin/bash -e -x

if [ "$#" -lt 1  ]; then
    echo "Usage: $0 <Build path>"
    exit -1
fi

OPT_FLAGS="-O3"
MAKE_JOBS=$(sysctl -n hw.ncpu)
MIN_IOS_VERSION="9.0"
BUILD_PATH="${1}"

dobuild() {
    export CC="$(xcrun -find -sdk ${SDK} cc)"
    export CXX="$(xcrun -find -sdk ${SDK} cxx)"
    export CPP="$(xcrun -find -sdk ${SDK} cpp)"
    export CFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
    export CXXFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
    export LDFLAGS="${HOST_FLAGS} --specs=nosys.specs"

    autoreconf -i
    ./configure --host=${CHOST} --prefix="${BUILD_PATH}/${PREFIX}" --enable-static --disable-shared

    make clean
    make -j${MAKE_JOBS}
    make install
}

SDK="iphoneos"
ARCH_FLAGS="-arch armv7"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
PREFIX="device_arm"
dobuild

SDK="iphoneos"
ARCH_FLAGS="-arch arm64"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
PREFIX="device_arm64"
dobuild

SDK="iphonesimulator"
ARCH_FLAGS="-arch i386"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="i386-apple-darwin"
PREFIX="simulator_i386"
dobuild

SDK="iphonesimulator"
ARCH_FLAGS="-arch x86_64"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="x86_64-apple-darwin"
PREFIX="simulator_x86_64"
dobuild
