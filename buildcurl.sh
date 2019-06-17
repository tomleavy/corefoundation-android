export ARCH=aarch64-linux-android
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

if [ -f ${PWD}/curl/output/lib/libcurl.la ]; then
    exit 0
fi

# Clone
git clone https://github.com/curl/curl.git
cd curl && git checkout curl-7_65_1

# Build

autoreconf -i
./configure --host=${ARCH} --enable-shared --disable-static \
    --disable-dependency-tracking --with-zlib=${TOOLCHAIN}/sysroot/usr \
    --with-ssl=`realpath ../openssl/output` \
    --without-ca-bundle --without-ca-path --enable-ipv6 \
    --enable-http --enable-ftp --disable-file --disable-ldap \
    --disable-ldaps --disable-rtsp --disable-proxy --disable-dict \
    --disable-telnet --disable-tftp --disable-pop3 --disable-imap \
    --disable-smtp --disable-gopher --disable-sspi --disable-manual \
    --target=${ARCH} --build=x86_64-unknown-linux-gnu --prefix=`realpath ./output`

make -j8
make install
