#!/bin/bash
echo "Cleaning old files"
rm -f ../img/Tyr*
rm -f ../img/boot.img
rm -f ../ramdisk/ramdisk_one_plus_one/image-new*
rm -f ../ramdisk/ramdisk_one_plus_one/ramdisk-new.cpio*
rm -f ../ramdisk/ramdisk_one_plus_one/split_img/boot.img-dtb
rm -f ../ramdisk/ramdisk_one_plus_one/split_img/boot.img-zImage
echo "Making Oneplus one CAF kernel"
DATE_START=$(date +"%s")

cd ../kernels/android_kernel_oneplus_msm8974
make clean && make mrproper

VER=9
export KBUILD_BUILD_VERSION=$VER
export KBUILD_BUILD_USER=DerRomtester
export KBUILD_BUILD_HOST=kernel
export ARCH=arm
export SUBARCH=arm
export COMPILER=clang
export COMPILER_PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9
export PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9/bin/:$PATH
make ARCH=arm CROSS_COMPILE=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9/bin/arm-eabi- -l4 -j5 COMPILER_PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 GCC_TOOLCHAIN=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 HOSTCC="/home/stefan/clang/Release/bin/clang" CC="/home/stefan/clang/Release/bin/clang --target=armv7a-none-linux -march=armv7-a -mfpu=neon -no-integrated-as -fno-builtin-memcpy -ffreestanding -fcolor-diagnostics -I/home/stefan/llvmlinux/toolchain/clang/head/src/clang/lib/Headers -Wno-unused-parameter --gcc-toolchain=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 " bacon_defconfig
make ARCH=arm CROSS_COMPILE=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9/bin/arm-eabi- -l4 -j5 COMPILER_PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 GCC_TOOLCHAIN=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 HOSTCC="/home/stefan/clang/Release/bin/clang" CC="/home/stefan/clang/Release/bin/clang --target=armv7a-none-linux -march=armv7-a -mfpu=neon -no-integrated-as -fno-builtin-memcpy -ffreestanding -fcolor-diagnostics -I/home/stefan/llvmlinux/toolchain/clang/head/src/clang/lib/Headers -Wno-unused-parameter --gcc-toolchain=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 "
echo "End of compiling kernel!"

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
cd ../../scripts
../ramdisk/ramdisk_one_plus_one/dtbToolCM -2 -o ../ramdisk/ramdisk_one_plus_one/split_img/boot.img-dtb -s 2048 -p ../kernels/android_kernel_oneplus_msm8974/scripts/dtc/ ../kernels/android_kernel_oneplus_msm8974/arch/arm/boot/
cp ../kernels/android_kernel_oneplus_msm8974/arch/arm/boot/zImage ../ramdisk/ramdisk_one_plus_one/split_img/boot.img-zImage
cd ../ramdisk/ramdisk_one_plus_one/
./repackimg.sh
cd ../../kernels/android_kernel_oneplus_msm8974/
zipfile="TyrV$VER.zip"
echo "making zip file"
cp ../../ramdisk/ramdisk_one_plus_one/image-new.img ../../img/boot.img
cd ../../img/
rm -f *.zip
zip -r -9 $zipfile *
rm -f /tmp/*.zip
cp *.zip /tmp
