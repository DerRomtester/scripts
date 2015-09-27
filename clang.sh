#!/bin/bash
echo "Cleaning old files"
rm -f ../ramdisk/opo-AnyKernel2/dtb
rm -f ../ramdisk/opo-AnyKernel2/zImage
rm -f ../output/Tyr*.zip
echo "Making Oneplus One CM12.1 kernel"
DATE_START=$(date +"%s")
cd ../kernels/one_plus_one
make clean && make mrproper

VER=147
# release
export KBUILD_BUILD_VERSION=$VER
export KBUILD_BUILD_USER=DerRomtester
export KBUILD_BUILD_HOST=kernel
export ARCH=arm
export SUBARCH=arm
export COMPILER=clang
export COMPILER_PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9
export PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9/bin/:$PATH
make ARCH=arm CROSS_COMPILE=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9/bin/arm-eabi- -l4 -j5 COMPILER_PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 GCC_TOOLCHAIN=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 HOSTCC="/home/stefan/clang/Release/bin/clang" CC="/home/stefan/clang/Release/bin/clang --target=armv7a-none-linux -march=armv7-a -mfpu=neon -no-integrated-as -fno-builtin-memcpy -ffreestanding -fcolor-diagnostics -I/home/stefan/llvmlinux/toolchain/clang/head/src/clang/lib/Headers -Wno-unused-parameter --gcc-toolchain=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 " Tyr_defconfig
make ARCH=arm CROSS_COMPILE=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9/bin/arm-eabi- -l4 -j5 COMPILER_PATH=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 GCC_TOOLCHAIN=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 HOSTCC="/home/stefan/clang/Release/bin/clang" CC="/home/stefan/clang/Release/bin/clang --target=armv7a-none-linux -march=armv7-a -mfpu=neon -no-integrated-as -fno-builtin-memcpy -ffreestanding -fcolor-diagnostics -I/home/stefan/llvmlinux/toolchain/clang/head/src/clang/lib/Headers -Wno-unused-parameter --gcc-toolchain=/home/stefan/build/toolchains/UBERTC-arm-eabi-4.9 "
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
