#!/bin/bash
set -e 

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
  export ARCH=i686-linux-android${API_LEVEL}
  export ARCH_HOST=i686-linux-android${API_LEVEL}
elif [ "${ABI}" == "x86_64" ]
then
  export ARCH=x86_64-linux-android${API_LEVEL}
  export ARCH_HOST=x86_64-linux-android${API_LEVEL}
elif [ "${ABI}" == "armeabi-v7a" ]
then
  export ARCH=armv7a-linux-androideabi${API_LEVEL}
  export ARCH_HOST=arm-linux-androideabi${API_LEVEL}
elif [ "${ABI}" == "arm64-v8a" ]
then
  export ARCH=aarch64-linux-android${API_LEVEL}
  export ARCH_HOST=aarch64-linux-android${API_LEVEL}
else
  echo "Invalid ABI value entered: $1"
  echo "Usage: $(basename $0) <x86|x86_64|armeabi-v7a|arm64-v8a>"
  exit 1
fi

./buildxml.sh
./builddispatch.sh

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Starting build of CoreFoundation for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"



if [ ! -d swift-corelibs-foundation ]; then 
    git clone https://github.com/swiftlang/swift-corelibs-foundation.git
fi 

cd swift-corelibs-foundation

mkdir -p output
mkdir -p output/lib
mkdir -p output/include/CoreFoundation
mkdir -p build && cd build

cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
    -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DANDROID_ABI=${ABI} \
    -DCMAKE_INSTALL_PREFIX=../output \
    -DFOUNDATION_BUILD_NETWORKING=false \
    -DLIBXML2_LIBRARY=`realpath ../../libxml2/output/lib/libxml2.a` \
    -DLIBXML2_INCLUDE_DIR=../../libxml2/output/include/libxml2 \
    -DDISPATCH_INCLUDE_PATH=../../swift-corelibs-libdispatch/output/include \
    -G Ninja \
    ../

cmake --build . --target CoreFoundation

cp ./lib/libCoreFoundation.a ../output/lib
cp ../../swift-corelibs-libdispatch/output/lib/*.a ../output/lib
cp ./lib/*.a ../output/lib
cp ../Sources/CoreFoundation/include/*.h ../output/include/CoreFoundation

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished build of CoreFoundation for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
