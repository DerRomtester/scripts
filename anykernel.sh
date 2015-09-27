#!/bin/bash
echo "Cleaning old files"
rm -f ../ramdisk/opo-AnyKernel2/dtb
rm -f ../ramdisk/opo-AnyKernel2/zImage
rm -f ../output/Tyr*.zip
echo "Making Oneplus One CM12.1 kernel"
DATE_START=$(date +"%s")
cd ../kernels/one_plus_one
make clean && make mrproper

VER=149
# release
export KBUILD_BUILD_VERSION=$VER
export KBUILD_BUILD_USER=DerRomtester
export KBUILD_BUILD_HOST=kernel
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/home/stefan/build/toolchains/UBERTC-arm-eabi-6.0/bin/arm-eabi-
make Tyr_defconfig
make -j8
echo "End of compiling kernel!"

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
cd ../../scripts
../ramdisk/opo-AnyKernel2/tools/dtbToolCM -2 -o ../ramdisk/opo-AnyKernel2/dtb -s 2048 -p ../kernels/one_plus_one/scripts/dtc/ ../kernels/one_plus_one/arch/arm/boot/
cp ../kernels/one_plus_one/arch/arm/boot/zImage ../ramdisk/opo-AnyKernel2/zImage
cd ../ramdisk/opo-AnyKernel2/
zipfile="TyrV$VER.zip"
zip -r -9 $zipfile *
mv TyrV$VER.zip ../../output/
