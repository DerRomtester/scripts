#!/bin/bash
echo "Cleaning old files"
rm -f ../ramdisk/opo-AnyKernel2/dtb
rm -f ../ramdisk/opo-AnyKernel2/zImage
rm -f ../output/Tyr*.zip
rm -f ../img/Tyr*
rm -f ../img/boot.img
rm -f ../ramdisk/ramdisk_one_plus_one/image-new*
rm -f ../ramdisk/ramdisk_one_plus_one/ramdisk-new.cpio*
rm -f ../ramdisk/ramdisk_one_plus_one/split_img/boot.img-dtb
rm -f ../ramdisk/ramdisk_one_plus_one/split_img/boot.img-zImage
echo "Making Oneplus one CAF kernel V$VER"
DATE_START=$(date +"%s")

cd ../kernels/android_kernel_oneplus_msm8974
make clean && make mrproper

VER=19
export KBUILD_BUILD_VERSION=$VER
export KBUILD_BUILD_USER=DerRomtester
export KBUILD_BUILD_HOST=kernel
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/home/stefan/build/toolchains/linaro-lto/bin/arm-eabi-
make bacon_defconfig
make -j8
echo "End of compiling kernel!"

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
cd ../../scripts
../ramdisk/opo-AnyKernel2/tools/dtbToolCM -2 -o ../ramdisk/opo-AnyKernel2/dtb -s 2048 -p ../kernels/android_kernel_oneplus_msm8974/scripts/dtc/ ../kernels/android_kernel_oneplus_msm8974/arch/arm/boot/
cp ../kernels/android_kernel_oneplus_msm8974/arch/arm/boot/zImage ../ramdisk/opo-AnyKernel2/zImage
cd ../ramdisk/opo-AnyKernel2/
zipfile="TyrV$VER.zip"
zip -r -9 $zipfile *
mv TyrV$VER.zip ../../output/
