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

    ./configure --target=${CTARGET} \
                --prefix="${BUILD_PATH}/${PREFIX}" \
                --enable-static \
                --disable-shared \
                --enable-optimizations \
                --enable-pic \
                --disable-ccache \
                --disable-debug \
                --disable-gprof \
                --disable-gcov \
                --disable-thumb \
                --enable-dependency-tracking \
                --disable-install-docs \
                --enable-install-bins \
                --enable-install-libs \
                --disable-install-srcs \
                --enable-libs \
                --disable-examples \
                --disable-tools \
                --disable-docs \
                --enable-unit-tests \
                --disable-decode-perf-tests \
                --disable-encode-perf-tests \
                --disable-codec-srcs \
                --disable-debug-libs \
                --enable-better-hw-compatibility \
                --disable-vp8 \
                --enable-vp9 \
                --disable-internal-stats \
                --enable-postproc \
                --enable-vp9-postproc \
                --enable-multithread \
                --enable-spatial-resampling \
                --enable-realtime-only \
                --enable-onthefly-bitpacking \
                --enable-error-concealment \
                --disable-coefficient-range-checking \
                --disable-runtime-cpu-detect \
                --enable-postproc-visualizer \
                --enable-multi-res-encoding \
                --enable-vp9-temporal-denoising \
                --enable-webm-io \
                --enable-libyuv

    make clean
    make -j${MAKE_JOBS}
    make install
}

SDK="iphoneos"
ARCH_FLAGS="-arch armv7"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CTARGET="armv7-darwin-gcc"
PREFIX="device_arm"
dobuild

SDK="iphoneos"
ARCH_FLAGS="-arch arm64"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CTARGET="arm64-darwin-gcc"
PREFIX="device_arm64"
dobuild

SDK="iphonesimulator"
ARCH_FLAGS="-arch i386"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CTARGET="x86-iphonesimulator-gcc"
PREFIX="simulator_i386"
dobuild

SDK="iphonesimulator"
ARCH_FLAGS="-arch x86_64"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CTARGET="x86_64-iphonesimulator-gcc"
PREFIX="simulator_x86_64"
dobuild
