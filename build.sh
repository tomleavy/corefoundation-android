#!/bin/bash

if [ $# -gt 2 ] || [ $# -eq 0 ]; then
    echo "Usage: $(basename $0) <x86|x86_64|armeabi-v7a|arm64-v8a> [Release|Debug]"
    exit 1
fi

if [ $# -eq 2 ]; then
  export BUILD_TYPE=$2
else
  export BUILD_TYPE=Release
fi

if [ "${BUILD_TYPE}" == "Release" ]
then
  echo "Building a RELEASE version"
elif [ "${BUILD_TYPE}" == "Debug" ]
then
  echo "Building a DEBUG version"
else
    echo "Invalid build type: ${BUILD_TYPE}"
    echo "Usage: $(basename $0) <x86|x86_64|armeabi-v7a|arm64-v8a> [Release|Debug]"
    exit 1
fi

export ABI=$1
export API_LEVEL=21

if [ "${ABI}" == "x86" ]
then
  export ARCH=i686-linux-android
  export ARCH_LNK=i686-linux-android
  export ARCH_HOST=i686-linux-android
  export OPENSSL_ABI=android-x86
elif [ "${ABI}" == "x86_64" ]
then
  export ARCH=x86_64-linux-android
  export ARCH_LNK=x86_64-linux-android
  export ARCH_HOST=x86_64-linux-android
  export OPENSSL_ABI=android-x86_64
elif [ "${ABI}" == "armeabi-v7a" ]
then
  export ARCH=armv7a-linux-androideabi
  export ARCH_LNK=arm-linux-androideabi
  export ARCH_HOST=arm-linux-androideabi
  export OPENSSL_ABI=android-arm
elif [ "${ABI}" == "arm64-v8a" ]
then
  export ARCH=aarch64-linux-android
  export ARCH_LNK=aarch64-linux-android
  export ARCH_HOST=aarch64-linux-android
  export OPENSSL_ABI=android-arm64
else
  echo "Invalid ABI value entered: $1"
  echo "Usage: $(basename $0) <x86|x86_64|armeabi-v7a|arm64-v8a>"
  exit 1
fi

./buildOpenSSL.sh
./buildxml.sh
./buildICU.sh
./buildcurl.sh
./builddispatch.sh

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Starting build of CoreFoundation for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"


git clone https://github.com/tomleavy/swift-corelibs-foundation.git
cd swift-corelibs-foundation && git checkout tl-androidcf

cd CoreFoundation
mkdir output
mkdir -p build && cd build

CF_CFLAGS="-D_POSIX_THREADS=1 -isystem `realpath ../Base.subproj/SwiftRuntime` -isystem `realpath ../../`"
CF_LINKER_FLAGS="-L`realpath ../../../icu/icu4c/output/lib` -L`realpath ../../../swift-corelibs-libdispatch/output/lib` -licudata -licui18n  -licuio -licutest -licutu -licuuc"

echo $CF_CFLAGS

cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
    -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DANDROID_ABI=${ABI} \
    -DCMAKE_INSTALL_PREFIX=../output \
    -DLIBXML2_LIBRARY=`realpath ../../../libxml2/output/lib/libxml2.a` \
    -DLIBXML2_INCLUDE_DIR=../../../libxml2/output/include/libxml2 \
    -DCURL_LIBRARY=`realpath ../../../curl/output/lib/libcurl.so` \
    -DCURL_INCLUDE_DIR=../../../curl/output/include \
    -DICU_LIBRARY="`realpath ../../../icu/icu4c/output/lib/libicuua.a`;`realpath ../../../icu/icu4c/output/libicui18n.a`" \
    -DICU_INCLUDE_DIR=../../../icu/icu4c/output/include \
    -DCF_PATH_TO_LIBDISPATCH_SOURCE=`realpath ../../../swift-corelibs-libdispatch` \
    -DCF_PATH_TO_LIBDISPATCH_BUILD=../../../swift-corelibs-libdispatch/output \
    -DCMAKE_C_FLAGS="${CF_CFLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${CF_LINKER_FLAGS}" \
    ../

make -j8 VERBOSE=1
make install

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished build of CoreFoundation for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
