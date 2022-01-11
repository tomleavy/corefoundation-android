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

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Starting work for Curl for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"

export API_LEVEL=21
export HOST_TAG=linux-x86_64

export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
export AR=$TOOLCHAIN/bin/${ARCH_LNK}-ar
export AS=$TOOLCHAIN/bin/${ARCH_LNK}-as
export CC=$TOOLCHAIN/bin/${ARCH}${API_LEVEL}-clang
export CXX=$TOOLCHAIN/bin/${ARCH}${API_LEVEL}-clang++
export LD=$TOOLCHAIN/bin/${ARCH_LNK}-ld
export RANLIB=$TOOLCHAIN/bin/${ARCH_LNK}-ranlib
export STRIP=$TOOLCHAIN/bin/${ARCH_LNK}-strip
export PATH=${TOOLCHAIN}/bin:${PATH}

if [ -f ${PWD}/curl/output/lib/libcurl.la ]; then
    exit 0
fi

# Clone
git clone https://github.com/curl/curl.git
cd curl && git checkout curl-7_65_1

if [[ -z PREBUILT_OPENSSL ]]; then
    OPENSSL_DIR=`realpath ../openssl/output`
else
    OPENSSL_DIR="${PREBUILT_OPENSSL}"
fi

# Build

autoreconf -i
./configure \
    --host=${ARCH_HOST} \
    --enable-static --disable-shared \
    --disable-dependency-tracking --with-zlib=${TOOLCHAIN}/sysroot/usr \
    --with-ssl=${OPENSSL_DIR}/${ABI} \
    --without-ca-bundle --without-ca-path --enable-ipv6 \
    --enable-http --enable-ftp --disable-file --disable-ldap \
    --disable-ldaps --disable-rtsp --disable-proxy --disable-dict \
    --disable-telnet --disable-tftp --disable-pop3 --disable-imap \
    --disable-smtp --disable-gopher --disable-sspi --disable-manual \
    --build=x86_64-unknown-linux-gnu --prefix=`realpath ./output`

make -j8
make install

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished work for Curl for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
