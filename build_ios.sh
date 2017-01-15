#!/bin/bash -e -x

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <Build path>"
    exit -1
fi

BUILD_PATH="${1}"
mkdir -p "${BUILD_PATH}"

OPT_FLAGS="-O3"
MAKE_JOBS=$(sysctl -n hw.ncpu)
MIN_IOS_VERSION="9.0"

DEVICE_ARM="device_arm"
DEVICE_ARM64="device_arm64"
SIMULATOR_I386="simulator_i386"
SIMULATOR_X86_64="simulator_x86_64"

dobuild() {
    export CC="$(xcrun -find -sdk ${SDK} cc)"
    export CXX="$(xcrun -find -sdk ${SDK} cxx)"
    export CPP="$(xcrun -find -sdk ${SDK} cpp)"
    export CFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
    export CXXFLAGS="${CFLAGS}"
    export LDFLAGS="${HOST_FLAGS}"
    export PKG_CONFIG_PATH="${BUILD_PATH}/${PREFIX}/lib/pkgconfig"

    autoreconf -i
    ./configure --host=${CHOST} \
				--prefix="${BUILD_PATH}/${PREFIX}" \
				--enable-static \
				--disable-shared \
				--enable-av \
				--with-libsodium-headers="${BUILD_PATH}/${PREFIX}/include" \
				--with-libsodium-libs="${BUILD_PATH}/${PREFIX}/lib"

    make clean
    make -j${MAKE_JOBS}
    make install
}

SDK="iphoneos"
ARCH_FLAGS="-arch armv7"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
PREFIX="${DEVICE_ARM}"
dobuild

SDK="iphoneos"
ARCH_FLAGS="-arch arm64"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
PREFIX="${DEVICE_ARM64}"
dobuild

SDK="iphonesimulator"
ARCH_FLAGS="-arch i386"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="i386-apple-darwin"
PREFIX="${SIMULATOR_I386}"
dobuild

SDK="iphonesimulator"
ARCH_FLAGS="-arch x86_64"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=${MIN_IOS_VERSION} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="x86_64-apple-darwin"
PREFIX="${SIMULATOR_X86_64}"
dobuild

LIB_FILES=( \
            libtoxav.a \
            libtoxcore.a \
            libtoxdns.a \
            libtoxencryptsave.a \
            libopus.a \
            libsodium.a \
            libvpx.a \
          )

mkdir -p "${BUILD_PATH}/lib"

for INDEX in "${!LIB_FILES[@]}"; do
    LIB_FILE="${LIB_FILES[$INDEX]}"
    lipo -create "${BUILD_PATH}/${DEVICE_ARM}/lib/${LIB_FILE}" \
                 "${BUILD_PATH}/${DEVICE_ARM64}/lib/${LIB_FILE}" \
                 "${BUILD_PATH}/${SIMULATOR_I386}/lib/${LIB_FILE}" \
                 "${BUILD_PATH}/${SIMULATOR_X86_64}/lib/${LIB_FILE}" \
         -output "${BUILD_PATH}/lib/${LIB_FILE}"
done

cp -r "${BUILD_PATH}/${DEVICE_ARM}/include" "${BUILD_PATH}/"
