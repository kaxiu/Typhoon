#!/bin/bash

echo '----------------------------------------------------------------------------------------------------'
echo "Building requires the following dependencies to be installed"
echo '----------------------------------------------------------------------------------------------------'
echo "gem install xcpretty"
echo "sudo port install lcov"
echo "sudo port install groovy"
echo "sudo port install doxygen"
echo "sudo port install graphviz"
echo '----------------------------------------------------------------------------------------------------'

#Configuration
reportsDir=build/reports
sourceDir=Source



requiredCoverage=85

#Fail immediately if a task fails
set -e
set -o pipefail


#Clean
rm -fr ~/Library/Developer/Xcode/DerivedData
rm -fr ./build

#Init submodules
git submodule init
git submodule update

#Stamp build Initially failing
ditto ${resourceDir}/build-failed.png ${reportsDir}/build-status/build-status.png


#Compile, run tests and produce coverage report for iOS Simulator
platform=iOS_Simulator

rm -fr ~/Library/Developer/Xcode/DerivedData
xcodebuild test -project Typhoon.xcodeproj -scheme 'Typhoon-iOSTests' -configuration Debug \
-destination 'platform=iOS Simulator,name=iPhone 5s,OS=8.1' | xcpretty -c --report junit
ditto ${reportsDir}/junit.xml ${reportsDir}/${platform}/junit.xml

groovy http://frankencover.it/with --source-dir Source --output-dir ${reportsDir}/iOS_Simulator -r${requiredCoverage}
echo '----------------------------------------------------------------------------------------------------'


#Compile, run tests and produce coverage report for OSX
platform=OSX

rm -fr ~/Library/Developer/Xcode/DerivedData
xcodebuild -project Typhoon.xcodeproj/ -scheme 'Typhoon-OSXTests' test | xcpretty -c --report junit
ditto ${reportsDir}/junit.xml ${reportsDir}/${platform}/junit.xml

groovy http://frankencover.it/with --source-dir Source --output-dir ${reportsDir}/OSX -r${requiredCoverage}
echo '--------------------------------------------------------------------------------'


#Stamp build passing
ditto ${resourceDir}/build-passed.png ${reportsDir}/build-status/build-status.png
