if [ "$ARCH" == "" ]
then
  echo "$(basename $0): ARCH has not been set!"
  exit 1
fi

if [ "$ARCH_LNK" == "" ]
then
  echo "$(basename $0): ARCH_LNK has not been set!"
  exit 1
fi

if [ -f ./icu/icu4c/output/libicuuc.a ]; then
    exit 0
fi

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Starting work for ICU for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"

git clone https://github.com/unicode-org/icu.git && cd icu && git checkout release-64-2 

cd icu4c

mkdir macos && cd macos

../source/runConfigureICU MacOSX \

make -j8

export API_LEVEL=28
export HOST_TAG=darwin-x86_64

export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
export AR=$TOOLCHAIN/bin/${ARCH_LNK}-ar
export AS=$TOOLCHAIN/bin/${ARCH_LNK}-as
export CC=$TOOLCHAIN/bin/${ARCH}${API_LEVEL}-clang
export CXX=$TOOLCHAIN/bin/${ARCH}${API_LEVEL}-clang++
export LD=$TOOLCHAIN/bin/${ARCH_LNK}-ld
export RANLIB=$TOOLCHAIN/bin/${ARCH_LNK}-ranlib
export STRIP=$TOOLCHAIN/bin/${ARCH_LNK}-strip
export PATH=${TOOLCHAIN}/bin:${PATH}

cd ../source && autoreconf -i && cd ../ && mkdir android && cd android

../source/configure --prefix=$(PWD)../../output \
    --host=${ARCH_HOST} \
    --enable-static \
    --with-data-packaging=archive \
    --with-cross-build="$(realpath ../macos)" \
    --disable-shared \
    CXXFLAGS="-fPIC -std=c++11"

make -j8 && make install

cd ../output/lib

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished work for ICU for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
