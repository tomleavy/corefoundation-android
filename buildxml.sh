if [ "$ARCH" == "" ]
then
  echo "$(basename $0): ARCH has not been set!"
  exit 1
fi

export API_LEVEL=21
export HOST_TAG=linux-x86_64

export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
export AR=$TOOLCHAIN/bin/llvm-ar
export AS=$TOOLCHAIN/bin/llvm-as
export CC=$TOOLCHAIN/bin/${ARCH}-clang
export CXX=$TOOLCHAIN/bin/${ARCH}-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
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

#make -j8 libxml2.la && make install-libLTLIBRARIES
make -j8 && make install
#cd include && make install

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished work for XML for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
