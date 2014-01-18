#!/bin/sh
set -e

xcodebuild -project Followers.xcodeproj -scheme Followers -sdk iphonesimulator7.0 clean
xcodebuild -project Followers.xcodeproj -scheme Followers -sdk iphonesimulator7.0 build
xcodebuild -project Followers.xcodeproj -scheme Followers -sdk iphonesimulator7.0 test
