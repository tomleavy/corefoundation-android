if [ "$ABI" == "" ]
then
  echo "$(basename $0): ABI has not been set!"
  exit 1
fi

if [ "$BUILD_TYPE" == "" ]
then
  echo "BUILD_TYPE not set, setting to Release"
  BUILD_TYPE=Release
fi

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Starting work for Dispatch for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"

export API_LEVEL=28

if [ -d ./swift-corelibs-libdispatch/output ]; then
    exit 0
fi

git clone https://github.com/apple/swift-corelibs-libdispatch.git
cd swift-corelibs-libdispatch && git checkout swift-5.0.1-RELEASE

mkdir output
mkdir build && cd build

cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
    -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DANDROID_ABI=${ABI} \
    -DCMAKE_INSTALL_PREFIX=../output \
    ../

make -j8
make install

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished work for Dispatch for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
