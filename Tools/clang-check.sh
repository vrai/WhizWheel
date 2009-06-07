#!/bin/bash

# ----------------------------------------------------------------------------
#                WhizWheel, copyright Vrai Stacey 2009
#
# $Id$
#
# Build utility that uses the LLVM/Clang Static Analyzer to find potential
# memory leaks. Requires that the analyzer be installed and that "scan-build"
# (in the analyzer's root directory) is in the PATH.
#
# The latest version of the analyzer can be downloaded from: 
#     http://clang.llvm.org/StaticAnalysis.html
# ----------------------------------------------------------------------------

# Exit the script on first error
set -e

if [ -z "$1" ]
then
    echo "Usage: $0 BUILD_NAME"
    echo
    echo "    By default the available builds are named \"Debug\" and \"Release\"."
    echo
    exit 1
fi
echo $1

# Two stages - first clean out the build directory (to ensure a consistent
# build), then perform the build + analysis.
scan-build --view xcodebuild -configuration $1 clean
scan-build --view xcodebuild -configuration $1
