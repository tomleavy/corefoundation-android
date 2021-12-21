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

if [ "$OPENSSL_ABI" == "" ]
then
  echo "$(basename $0): OPENSSL_ABI has not been set!"
  exit 1
fi

if [ "${ABI}" == "x86" ]
then
  export OPTION_64BIT=
elif [ "${ABI}" == "x86_64" ]
then
  export OPTION_64BIT=enable-ec_nistp_64_gcc_128
elif [ "${ABI}" == "armeabi-v7a" ]
then
  export OPTION_64BIT=
elif [ "${ABI}" == "arm64-v8a" ]
then
  export OPTION_64BIT=enable-ec_nistp_64_gcc_128
else
  echo "Invalid ABI value entered: $1"
  exit 1
fi

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Starting build of OpenSSL for ABI=${ABI}"
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

# Download

mkdir -p openssl && cd openssl
mkdir output

if [ -f output/lib/libcrypto.a ]; then
    exit 0
fi

wget https://www.openssl.org/source/openssl-1.1.1f.tar.gz

SHA256=`sha256sum openssl-1.1.1f.tar.gz`

echo $SHA256

if [[ "${SHA256}" -eq "186c6bfe6ecfba7a5b48c47f8a1673d0f3b0e5ba2e25602dd23b629975da3f35 openssl-1.1.1f.tar.gz" ]]; then
    echo "Error, openssl sha256 hash doesn't match"
    exit 1
fi

tar -xvf openssl-1.1.1f.tar.gz
rm -rf openssl-1.1.1f.tar.gz
cd openssl-1.1.1f

./Configure -D__ANDROID_API__=${API_LEVEL} --prefix=$(PWD)/../output no-ssl3 no-comp ${OPTION_64BIT} ${OPENSSL_ABI}

make -j8
make install_sw 

echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
echo "Finished build of OpenSSL for ABI=${ABI}"
echo "*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*"
