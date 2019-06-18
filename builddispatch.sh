export ARCH=aarch64-linux-android
export ABI=arm64-v8a
export API_LEVEL=21

if [ -d ./swift-corelibs-libdispatch/output ]; then
    exit 0
fi

git clone https://github.com/apple/swift-corelibs-libdispatch.git
cd swift-corelibs-libdispatch && git checkout swift-5.0.1-RELEASE

mkdir output
mkdir build && cd build

cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
    -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
    -DCMAKE_BUILD_TYPE=Release \
    -DANDROID_ABI=${ABI} \
    -DCMAKE_INSTALL_PREFIX=../output \
    ../

make -j8
make install
