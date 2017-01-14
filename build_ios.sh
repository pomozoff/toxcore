#!/bin/bash -e -x

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <Build path> <Dependencies path>"
    exit -1
fi

BUILD_PATH="${1}"
if [ -d "${BUILD_PATH}" ]; then
    rm -fr "${BUILD_PATH}"
fi
mkdir -p "${BUILD_PATH}"

DEPS_PATH="${2}"
if [ ! -d "${DEPS_PATH}" ]; then
	echo "There is no directory ${DEPS_PATH}"
	exit -1
fi

OPT_FLAGS="-O3"
MAKE_JOBS=$(sysctl -n hw.ncpu)
MIN_IOS_VERSION="9.0"

dobuild() {
    export CC="$(xcrun -find -sdk ${SDK} cc)"
    export CXX="$(xcrun -find -sdk ${SDK} cxx)"
    export CPP="$(xcrun -find -sdk ${SDK} cpp)"
    export CFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
    export CXXFLAGS="${CFLAGS}"
    export LDFLAGS="${HOST_FLAGS}"
    export PKG_CONFIG_PATH="${DEPS_PATH}/${PREFIX}/lib/pkgconfig"

    autoreconf -i
    ./configure --host=${CHOST} \
				--prefix="${BUILD_PATH}/${PREFIX}" \
				--enable-static \
				--disable-shared \
				--enable-av \
				--with-libsodium-headers="${DEPS_PATH}/${PREFIX}/include" \
				--with-libsodium-libs="${DEPS_PATH}/${PREFIX}/lib"

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
