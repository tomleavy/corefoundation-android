./buildOpenSSL.sh
./buildxml.sh
./buildICU.sh
./buildcurl.sh
./builddispatch.sh

export API_LEVEL=21
export ABI=arm64-v8a

git clone https://github.com/tomleavy/swift-corelibs-foundation.git
cd swift-corelibs-foundation && git checkout tl-androidcf

cd CoreFoundation
mkdir output
mkdir -p build && cd build

cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
    -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
    -DCMAKE_BUILD_TYPE=Release \
    -DANDROID_ABI=${ABI} \
    -DCMAKE_INSTALL_PREFIX=../output \
    -DLIBXML2_LIBRARY=../../../libxml2/output/lib/libxml2.la \
    -DLIBXML2_INCLUDE_DIR=../../../libxml2/output/include/libxml2 \
    -DCURL_LIBRARY=../../../curl/output/libcurl.la \
    -DCURL_INCLUDE_DIR=../../../curl/output/include \
    -DICU_LIBRARY="../../../icu/icu4c/output/lib/libicuua.a;../../../icu/icu4c/output/libicui18n.a" \
    -DICU_INCLUDE_DIR=../../../icu/icu4c/output/include \
    -DCF_PATH_TO_LIBDISPATCH_SOURCE=`realpath ../../../swift-corelibs-libdispatch` \
    -DCF_PATH_TO_LIBDISPATCH_BUILD=../../../swift-corelibs-libdispatch/output \
    -DCMAKE_C_FLAGS="-D_POSIX_THREADS=1 -isystem `realpath ../Base.subproj/SwiftRuntime` -isystem `realpath ../../`" \
    ../

make -j8
make install

