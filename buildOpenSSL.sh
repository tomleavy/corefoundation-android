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
export PATH=${TOOLCHAIN}/bin:${PATH}

# Download

mkdir -p openssl && cd openssl
mkdir output

if [ -f output/lib/libcrypto.a ]; then
    exit 0
fi

wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz

SHA256=`sha256sum openssl-1.1.1c.tar.gz`

echo $SHA256

if [[ "${SHA256}" -eq "f6fb3079ad15076154eda9413fed42877d668e7069d9b87396d0804fdb3f4c90 openssl-1.1.1c.tar.gz" ]]; then
    echo "Error, openssl sha256 hash doesn't match"
    exit 1
fi

tar -xvf openssl-1.1.1c.tar.gz
rm -rf openssl-1.1.1c.tar.gz
cd openssl-1.1.1c

./Configure -D__ANDROID_API__=${API_LEVEL} --prefix=$(PWD)/../output no-ssl3 no-comp enable-ec_nistp_64_gcc_128 android-arm64

make -j8
make install_sw 
