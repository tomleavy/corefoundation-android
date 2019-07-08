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

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Starting work for XML for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"

if [ -f ${PWD}/libxml2/output/lib/libxml2.la ]; then
    exit 0
fi

# Checkout code
git clone https://github.com/GNOME/libxml2.git && cd libxml2 && git checkout v2.9.9

# Configure

mkdir output

autoreconf -i

./configure \
    --host=${ARCH_HOST} \
    --with-zlib=${TOOLCHAIN}/sysroot/usr \
    --without-python \
    --without-lzma \
    --enable-static \
    --disable-shared \
    --without-http \
    --without-html \
    --without-ftp \
    --prefix=${PWD}/output

# Make + Install

make -j8 libxml2.la && make install-libLTLIBRARIES
cd include && make install

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished work for XML for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
