#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

# 功能：将多个静态库整合成一个
# 使用方法：./push_to_repo_single.sh
#

reset="\033[0m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
cyan="\033[36m"
white="\033[37m"

# path
base_path=$(pwd)
echo $base_path

# Platform
iphoneos="iphoneos"
iphonesimulator="iphonesimulator"

# 整合每个架构的静态库 -> libquic.a
function libtoolToArchitecture() {
	
	cd $base_path/$1
	
	rm -rf mbedtls.a
	
	printf "$cyan> Building static framework: $1 \n"  >&2
	
	xcrun libtool -no_warning_for_no_symbols -static -o mbedtls.a *.a
	
	printf "$cyan> Finsh build static framework: $1 \n"  >&2
	
	cd ..
}

libtoolToArchitecture $iphoneos
libtoolToArchitecture $iphonesimulator

printf "$red> Start Merging static framework: mbedtls.xcframework \n" >&2

#lipo -create $iphoneos/mbedtls.a $iphonesimulator/mbedtls.a -output mbedtls.a

rm -rf ./mbedtls.xcframework

xcodebuild -create-xcframework -output mbedtls.xcframework \
-library $iphoneos/mbedtls.a \
-library $iphonesimulator/mbedtls.a

printf "$yellow> End Merging static framework: mbedtls.xcframework \n" >&2

