#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/xcframework"
OUTPUT_DIR="$ROOT_DIR/Distribution/Build"
SCHEME="${PAYKIT_SCHEME:-PayKit}"
PROJECT="${PAYKIT_XCODE_PROJECT:-}"
WORKSPACE="${PAYKIT_XCODE_WORKSPACE:-}"

if [ -n "$WORKSPACE" ]; then
  CONTAINER_ARGS="-workspace $WORKSPACE"
elif [ -n "$PROJECT" ]; then
  CONTAINER_ARGS="-project $PROJECT"
else
  echo "error: set PAYKIT_XCODE_PROJECT or PAYKIT_XCODE_WORKSPACE before building an XCFramework." >&2
  echo "example: PAYKIT_XCODE_PROJECT=PayKit.xcodeproj PAYKIT_SCHEME=PayKit Distribution/build-xcframework.sh" >&2
  exit 64
fi

rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

xcodebuild archive \
  $CONTAINER_ARGS \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$BUILD_DIR/PayKit-iOS.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
  $CONTAINER_ARGS \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$BUILD_DIR/PayKit-iOS-Simulator.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework "$BUILD_DIR/PayKit-iOS.xcarchive/Products/Library/Frameworks/PayKit.framework" \
  -framework "$BUILD_DIR/PayKit-iOS-Simulator.xcarchive/Products/Library/Frameworks/PayKit.framework" \
  -output "$OUTPUT_DIR/PayKit.xcframework"
