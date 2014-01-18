#!/bin/sh
set -e
set -x

GCOV_SRC_DIR=`xcodebuild -project Followers.xcodeproj -scheme Followers -showBuildSettings |grep -i " BUILD_DIR = " |awk -F= '{print $2}' |sed 's/ //g'`/..
echo GCOV_SRC_DIR = $GCOV_SRC_DIR
coveralls -b $GCOV_SRC_DIR --verbose -r .
