#!/bin/bash
#
# AK Kernel build script
#
# Copyright (C) 2016 @anarkia1976
#
# spinner author: @tlatsas (https://github.com/tlatsas)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# colors
white="\e[1;37m"
green="\e[1;32m"
red="\e[1;31m"
magenta="\e[1;35m"
cyan="\e[1;36m"
yellow="\e[1;33m"
blue="\e[1;34m"
restore="\e[0m"
blink_red="\e[05;31m"
bold="\e[1m"
invert="\e[7m"

# kernel version
KERNEL="Private"
VERSION="3"
RELEASE="${KERNEL}.00${VERSION}"

# local variables
CURRENT_DATE=`date +%Y%m%d`
CURRENT_TIME=`date +%H-%M-%S`
BUILD_LOG="/tmp/${CURRENT_DATE}_${RELEASE}.log"
THREAD="-j 8"

# kernel resources
ZIMAGE="zImage"
ZIMAGE_LOCATION="arch/arm/boot"
DTB="dtb"
DEFCONFIG="msm8974_find7op_defconfig"
TOOLCHAIN_CC="bin/arm-eabi-"
CCACHE=ccache

# path locations
SOURCE_DIR="/home/stefan/build"
KERNEL_DIR="kernels/android_kernel_oneplus_msm8974"
ANYKERNEL_DIR="ramdisk/opo-AnyKernel2-omni"
OUTPUT_DIR="output"
TOOLCHAIN_DIR="toolchains/DespairFactor-arm-eabi-4.9"

# shell export
export LOCALVERSION=~`echo ${RELEASE}`
export KBUILD_BUILD_VERSION=$VERSION
export CROSS_COMPILE="$CCACHE ${SOURCE_DIR}/${TOOLCHAIN_DIR}/${TOOLCHAIN_CC}"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=DerRomtester
export KBUILD_BUILD_HOST=kernel

# functions
function _spinner() {

    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="SUCCESS"
    local on_fail="FAILED"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-256
            # display message and position the cursor in $column column
            echo -ne "     ... ${2}"
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=0.15

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b[ "
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${restore}"
            else
                echo -en "${red}${on_fail}${restore}"
            fi
            echo -e " ]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

function clean_all {
    cd ${SOURCE_DIR}/${ANYKERNEL_DIR}
    echo -e "${bold}${blue}Clean ==============================================================${restore}"
    rm -rf zImage
    rm -rf ${DTB}
    git reset --hard
    git clean -f -d
    cd ${SOURCE_DIR}/${KERNEL_DIR}
    make clean
    make mrproper
    echo
} &>>$BUILD_LOG

function make_kernel {
    cd ${SOURCE_DIR}/${KERNEL_DIR}
    echo -e "${bold}${blue}Make ===============================================================${restore}"
    make ${DEFCONFIG}
    make ${THREAD}
    cp -vr ${ZIMAGE_LOCATION}/${ZIMAGE} ${SOURCE_DIR}/${ANYKERNEL_DIR}/zImage
    echo
} &>>$BUILD_LOG

function make_dtb {
    echo -e "${bold}${blue}Dtb ================================================================${restore}"
    ${SOURCE_DIR}/${ANYKERNEL_DIR}/tools/dtbToolCM -v2 -o ${SOURCE_DIR}/${ANYKERNEL_DIR}/${DTB} -s 2048 -p scripts/dtc/ ${ZIMAGE_LOCATION}/
    echo
} &>>$BUILD_LOG

function make_zip {
    echo -e "${bold}${blue}Zip ================================================================${restore}"
    cd ${SOURCE_DIR}/${ANYKERNEL_DIR}
    zip -r9 `echo ${RELEASE}`.zip * >> $BUILD_LOG 2>&1
    mv  `echo ${RELEASE}`.zip ${SOURCE_DIR}/${OUTPUT_DIR}
    cd ${SOURCE_DIR}/${KERNEL_DIR}
	echo
} &>>$BUILD_LOG

DATE_START=$(date +"%s")

if [[ ! -e ${BUILD_LOG} ]]; then
    touch ${BUILD_LOG}
fi

clear
echo -en "${white}"
echo '============================================'
echo ' AK KERNEL GENERATOR                        '
echo '============================================'
echo -en "${restore}"
echo
echo
echo
echo -en "${white}"
echo '============================================'
echo ' BUILD VERSION                              '
echo '============================================'
echo -en "${restore}"
echo
echo -en " ${bold}${blink_red}${RELEASE}${restore}"
echo
echo
echo -en "${white}"
echo '============================================'
echo -en "${restore}"
echo
echo -en "${white}"
echo '============================================'
echo ' CLEANING                                   '
echo '============================================'
echo -en "${restore}"
echo
while read -p "` echo -e " ${red}Y / N${restore} : "`" cchoice
do
case "${cchoice}" in
	y|Y )
		echo
		start_spinner CLEANING
		clean_all
		stop_spinner ALL DONE
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "     ... INVALID TRY AGAIN ..."
		echo
		;;
esac
done
echo
echo -en "${white}"
echo '============================================'
echo -en "${restore}"
echo
echo -en "${white}"
echo '============================================'
echo ' BUILDING                                   '
echo '============================================'
echo -en "${restore}"
echo
while read -p "` echo -e " ${red}Y / N${restore} : "`" dchoice
do
case "${dchoice}" in
	y|Y)
		echo
		start_spinner BUILDING
		make_kernel
		make_dtb
		make_zip
		stop_spinner ALL DONE
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "     ... INVALID TRY AGAIN ..."
		echo
		;;
esac
done
echo
echo -en "${white}"
echo '============================================'
echo -en "${restore}"
echo
echo -en "${white}"
echo '============================================'
echo ' ALL DONE                                   '
echo '============================================'
echo -en "${restore}"
echo
DATE_END=$(date +"%s")
DIFF=$((${DATE_END} - ${DATE_START}))
echo -e "${red}DEVICE${restore}  : ${DEVICE}"
echo -e "${red}VERSION${restore} : v.${VERSION}"
echo -e "${red}BASE${restore}    : ${BASE}"
echo -e "${red}TIME${restore}    : $((${DIFF} / 60)) minute(s) and $((${DIFF} % 60)) second(s)"
echo -e "${red}LOG DIR${restore} : ${BUILD_LOG}"
echo
echo -en "${white}"
echo '============================================'
echo -en "${restore}"
echo
