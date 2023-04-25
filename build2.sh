#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=MARKxDEVS
export KBUILD_BUILD_USER="AbzRaider"
mkdir clang && cd clang
bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=latest
sudo apt install libelf-dev libarchive-tools
bash -c "$(wget -O - https://gist.githubusercontent.com/dakkshesh07/240736992abf0ea6f0ee1d8acb57a400/raw/e97b505653b123b586fc09fda90c4076c8030732/patch-for-old-glibc.sh)"



 if ! [ -d "out" ]; then
echo "Kernel OUT Directory Not Found . Making Again"
mkdir out
fi

make O=out ARCH=arm64 lava_defconfig

PATH="${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
			ARCH=$ARCH \
			CC="clang" \
			CROSS_COMPILE=aarch64-linux-gnu- \
			CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                        LLVM=1 \
			LD=ld.lld \
			AR=llvm-ar \
			NM=llvm-nm \
			OBJCOPY=llvm-objcopy \
			OBJDUMP=llvm-objdump \
			STRIP=llvm-strip \
			CONFIG_NO_ERROR_ON_MISMATCH=y
                    }

function zupload()
{
rm -rf AnyKernel	
git clone --depth=1 https://github.com/AbzRaider/AnyKernel33 -b xm6768 AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
zip -r9 Test-OSS-KERNEL-XM6768-R.zip *
curl --upload-file "Test-OSS-KERNEL-XM6768-R.zip" https://free.keep.sh
}
compile
zupload
