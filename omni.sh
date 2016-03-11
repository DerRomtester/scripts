#!/bin/bash
../ramdisk/opo-AnyKernel2/tools/dtbToolCM -2 -o ../ramdisk/opo-AnyKernel2/dtb -s 2048 -p ../kernels/android_kernel_oppo_msm8974/scripts/dtc/ ../kernels/android_kernel_oppo_msm8974/arch/arm/boot/
cp ../kernels/android_kernel_oppo_msm8974/arch/arm/boot/zImage ../ramdisk/opo-AnyKernel2/zImage
cd ../ramdisk/opo-AnyKernel2/
zipfile="Your-Omnirom.zip"
zip -r -9 $zipfile *
mv *.zip ../../output/
