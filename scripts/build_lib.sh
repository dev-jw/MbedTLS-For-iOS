#!/bin/bash

# Yay shell scripting! This script builds a static version of
# MbedTLS for iOS and OSX that contains code for armv6, armv7, armv7s, arm64, x86_64.

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Setup paths to stuff we need
MBEDTLS_VERSION="2.7.0"
DIGEST="0b6fff22863e766e901464c8e2ce5ecc9c7d3a0b1a432c7504a47597c0408052"

run_cmake() {
	
	local IOS_PLATFORM=$1
	local MBEDTLS_SRC=$2
	local TYPE=$3
	
	mkdir -p ${BUILD_DIR}/build
		
	cd ../build
		 
	# clean cmake cache
	find . -iname '*cmake*' -not -name CMakeLists.txt -exec rm -rf {} +
	
	# cmake -> make
	cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/ios.toolchain.cmake -DIOS_PLATFORM=${IOS_PLATFORM} -DENABLE_PROGRAMS=OFF -DENABLE_TESTING=OFF -DINSTALL_MBEDTLS_HEADERS=OFF ../${MBEDTLS_SRC}/
	make
	
	# Add arch to library
	echo $PWD
	echo ${SCRIPT_DIR}
	if [ -f "${SCRIPT_DIR}/../${TYPE}/lib/libmbed*" ]; then
		cp -Rf ./library/libmbed* ${SCRIPT_DIR}/../${TYPE}/lib/
	else
		cp -Rf ./library/libmbed* ${SCRIPT_DIR}/../${TYPE}/lib/
	fi
	
	# Copy Header
	cp -Rf ../${MBEDTLS_SRC}/include/mbedtls/* ${SCRIPT_DIR}/../${TYPE}/include/	
	
	# Clean
	make clean
	rm -rf "${SRC_DIR}"
}

build() {
	local ARCH=$1
	local OS=$2
	local BUILD_DIR=$3
	local TYPE=$4 # iphoneos/iphonesimulator/macosx/macosx_catalyst
	
	local SRC_DIR="${BUILD_DIR}/mbedtls-${MBEDTLS_VERSION}-${TYPE}"
	local PREFIX="${BUILD_DIR}/${MBEDTLS_VERSION}-${OS}-${ARCH}"
	
	mkdir -p "${SRC_DIR}"
	tar xzf "${SCRIPT_DIR}/../mbedtls-${MBEDTLS_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1
	
	echo "Building for ${OS}"
	
	# Change dir
	cd "${SRC_DIR}"
	
	# 
	LOG_PATH="${PREFIX}.build.log"
	echo "Building ${LOG_PATH}"
	
	# run_cmake
	run_cmake $ARCH "mbedtls-${MBEDTLS_VERSION}-${TYPE}" $TYPE &> ${LOG_PATH}
	
	# build finish
	echo "Build Done!"
}

build_ios() {
	local TMP_BUILD_DIR=$( mktemp -d )
	
	# Copy tool
	cp -r ${SCRIPT_DIR}/../toolchain ${TMP_BUILD_DIR}/toolchain
	
	# Clean up whatever was left from our previous build
	rm -rf "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}
	mkdir -p "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}	
	build "DEVICE" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"
	
	rm -rf "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}
	mkdir -p "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}
	build "SIMULATOR" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"
	
	# Clean
	rm -rf ${TMP_BUILD_DIR}
}

# Start Download
if [ ! -f "${SCRIPT_DIR}/../mbedtls-${MBEDTLS_VERSION}.tar.gz" ]; then
	curl -fL "https://github.com/ARMmbed/mbedtls/archive/refs/tags/mbedtls-${MBEDTLS_VERSION}.tar.gz" -o "${SCRIPT_DIR}/../mbedtls-${MBEDTLS_VERSION}.tar.gz"
	
	if [[ "$(shasum -a 256 "../mbedtls-${MBEDTLS_VERSION}.tar.gz" | awk '{print $1}')" != "${DIGEST}" ]]
	then
		echo "mbedtls-${MBEDTLS_VERSION}.tar.gz: checksum mismatch"
		exit 1
	fi
fi

build_ios
	