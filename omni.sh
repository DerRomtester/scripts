#!/bin/bash
echo "Cleaning old files"
rm -f ../ramdisk/opo-AnyKernel2/dtb
rm -f ../ramdisk/opo-AnyKernel2/zImage
rm -f ../output/Tyr*.zip
echo "Making Oneplus one Omnirom kernel"
DATE_START=$(date +"%s")

cd ../kernels/android_kernel_oppo_msm8974
make clean && make mrproper

VER=1
export KBUILD_BUILD_VERSION=$VER
export KBUILD_BUILD_USER=DerRomtester
export KBUILD_BUILD_HOST=Kernel
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=//home/stefan/build/toolchain/arm-eabi-6.0/bin/arm-eabi-
make Tyr_defconfig
make -j8
echo "End of compiling kernel!"

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
cd ../../scripts
../ramdisk/opo-AnyKernel2/tools/dtbToolCM -2 -o ../ramdisk/opo-AnyKernel2/dtb -s 2048 -p ../kernels/android_kernel_oppo_msm8974/scripts/dtc/ ../kernels/android_kernel_oppo_msm8974/arch/arm/boot/
cp ../kernels/android_kernel_oppo_msm8974/arch/arm/boot/zImage ../ramdisk/opo-AnyKernel2/zImage
cd ../ramdisk/opo-AnyKernel2/
zipfile="TyrV$VER-Omnirom.zip"
zip -r -9 $zipfile *
mv TyrV$VER.zip ../../output/
