#!/bin/sh
set -e
set -x

GCOV_SRC_DIR=`xcodebuild -project Followers.xcodeproj -scheme Followers -showBuildSettings |grep -i " BUILD_DIR = " |awk -F= '{print $2}' |sed 's/ //g'`/..
echo GCOV_SRC_DIR = $GCOV_SRC_DIR

echo Find GCDA
find $GCOV_SRC_DIR -name \*.gcda
echo Find GCNO
find $GCOV_SRC_DIR -name \*.gcno


coveralls -r $GCOV_SRC_DIR --verbose -b . -x .m -x .h -x .mm -e SA_OAuth -e MGTwitter -e OAuthConsumer -e Followers\ Tests/

