if [ -f ./icu/icu4c/output/libicuuc.a ]; then
    exit 0
fi

git clone https://github.com/unicode-org/icu.git && cd icu && git checkout release-64-2 

cd icu4c

mkdir macos && cd macos

../source/runConfigureICU MacOSX \

make -j8

export ARCH=x86_64-linux-android
export API_LEVEL=21
export HOST_TAG=darwin-x86_64

export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
export AR=$TOOLCHAIN/bin/${ARCH}-ar
export AS=$TOOLCHAIN/bin/${ARCH}-as
export CC=$TOOLCHAIN/bin/${ARCH}${API_LEVEL}-clang
export CXX=$TOOLCHAIN/bin/${ARCH}${API_LEVEL}-clang++
export LD=$TOOLCHAIN/bin/${ARCH}-ld
export RANLIB=$TOOLCHAIN/bin/${ARCH}-ranlib
export STRIP=$TOOLCHAIN/bin/${ARCH}-strip
export PATH=${TOOLCHAIN}/bin:${PATH}

cd ../source && autoreconf -i && cd ../ && mkdir android && cd android

../source/configure --prefix=$(PWD)../../output --host=${ARCH} --enable-static --with-data-packaging=archive \
    --enable-shared \
    --with-cross-build="$(realpath ../macos)"

make -j8 && make install

cd ../output/lib

for f in *.so; do rm -rf "$f"; done
for f in *.so.64; do rm -rf "$f"; done
for f in *.so.64.2; do mv "$f" "$(echo "$f" | sed s/\.64\.2//)"; done
