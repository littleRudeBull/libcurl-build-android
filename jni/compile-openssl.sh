#!/bin/bash
# Compile curl & openssl & zlib for android with NDK.
# Copyright (C) 2018  shishuo <shishuo365@126.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

APP_ABI=(armeabi-v7a arm64-v8a)

BASE_PATH=$(
	cd "$(dirname $0)"
	pwd
)
SSL_PATH="$BASE_PATH/openssl"
BUILD_PATH="$BASE_PATH/build"

checkExitCode() {
	if [ $1 -ne 0 ]; then
		echo "Error building openssl library"
		cd $BASE_PATH
		exit $1
	fi
}
safeMakeDir() {
	if [ ! -x "$1" ]; then
		mkdir -p "$1"
	fi
}

## Android NDK
export NDK_ROOT="$NDK_ROOT"

if [ -z "$NDK_ROOT" ]; then
	echo "Please set your NDK_ROOT environment variable first"
	exit 1
fi

## Clean build directory
rm -rf $BUILD_PATH/openssl
safeMakeDir $BUILD_PATH/openssl

## Build OpenSSL

# compile $1 ABI $2 SYSROOT $3 TOOLCHAIN $4 MACHINE $5 SYSTEM $6 ARCH $7 CROSS_COMPILE
# http://wiki.openssl.org/index.php/Android
# http://doc.qt.io/qt-5/opensslsupport.html
compile() {
	cd $SSL_PATH
	ABI=$1
	SYSROOT=$2
	TOOLCHAIN=$3
	MACHINE=$4
	SYSTEM=$5
	ARCH=$6
	CROSS_COMPILE=$7
	# https://android.googlesource.com/platform/ndk/+/ics-mr0/docs/STANDALONE-TOOLCHAIN.html
	export SYSROOT=$SYSROOT
	export PATH="$TOOLCHAIN":"$PATH"
	# OpenSSL Configure
	export CROSS_COMPILE=$CROSS_COMPILE
	export ANDROID_DEV=$SYSROOT/usr
	export HOSTCC=gcc
	# Most of these should be OK (MACHINE, SYSTEM, ARCH).
	export MACHINE=$MACHINE
	export SYSTEM=$SYSTEM
	export ARCH=$ARCH
	# config
	safeMakeDir $BUILD_PATH/openssl/$ABI
	checkExitCode $?
	./Configure android no-shared --openssldir=$BUILD_PATH/openssl/$ABI
	checkExitCode $?
	# clean
	make clean
	checkExitCode $?
	# make
	make -j4 depend
	checkExitCode $?
	make -j4 all
	checkExitCode $?
	# install
	make install
	checkExitCode $?
	cd $BASE_PATH
}

# check system
host=$(uname | tr 'A-Z' 'a-z')
if [ $host = "darwin" ] || [ $host = "linux" ]; then
	echo "system: $host"
else
	echo "unsupport system, only support Mac OS X and Linux now."
	exit 1
fi

# for abi in ${APP_ABI[*]}; do
# 	case $abi in
# 	armeabi-v7a)
# 		compile $abi "$NDK_ROOT/platforms/android-12/arch-arm" "$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/$host-x86_64/bin" "armv7" "android" "arm" "arm-linux-androideabi-"
# 		;;
# 	x86)
# 		compile $abi "$NDK_ROOT/platforms/android-12/arch-x86" "$NDK_ROOT/toolchains/x86-4.9/prebuilt/$host-x86_64/bin" "i686" "android" "x86" "i686-linux-android-"
# 		;;
# 	arm64-v8a)
# 		compile $abi "$NDK_ROOT/platforms/android-21/arch-arm64" "$NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/$host-x86_64/bin" "armv8" "android64" "arm" "aarch64-linux-android-"
# 		;;
# 	*)
# 		echo "Error APP_ABI"
# 		exit 1
# 		;;
# 	esac
# done

# #armeabi-v7a
cd $SSL_PATH
make clean
export ARCH=armeabi-v7a 
export ANDROID_NDK=$NDK_ROOT
export PATH=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin:$PATH
./Configure android-arm -D__ANDROID_API__=12  no-shared  --prefix=$BUILD_PATH/openssl/$ARCH
 
make && make install

# #arm64-v8a
cd $SSL_PATH
make clean
export ARCH=arm64-v8a 
export ANDROID_NDK=$NDK_ROOT
export PATH=$ANDROID_NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin:$PATH
./Configure android-arm64 -D__ANDROID_API__=21 no-shared  --prefix=$BUILD_PATH/openssl/$ARCH

make && make install

cd $BASE_PATH
exit 0
