VERSION=1.4.0
CONFIGURATION=Release

all: build/AirTestFairy.ane

bin/bin/adt:
	rm -rf bin
	mkdir bin
	wget -P bin http://airdownload.adobe.com/air/mac/download/17.0/AIRSDK_Compiler.tbz2
	tar xf bin/AIRSDK_Compiler.tbz2 -C ./bin

ios/AirTestFairy/AirTestFairy/libTestFairy.a:
	curl -L -s -o ./ios/AirTestFairy/AirTestFairy/sdk.zip "http://app.testfairy.com/ios-sdk/TestFairySDK-${VERSION}.zip"
	unzip -q -o -d ./ios/AirTestFairy/AirTestFairy ./ios/AirTestFairy/AirTestFairy/sdk.zip libTestFairy.a TestFairy.h
	-rm -f ./ios/AirTestFairy/AirTestFairy/sdk.zip
	
build/ios/libAirTestFairy.a: ios/AirTestFairy/AirTestFairy/libTestFairy.a
	xcodebuild -project ./ios/AirTestFairy/AirTestFairy.xcodeproj -configuration $(CONFIGURATION) -sdk iphoneos
	xcodebuild -project ./ios/AirTestFairy/AirTestFairy.xcodeproj -configuration $(CONFIGURATION) -sdk iphonesimulator
	mkdir -p ios/build/$(CONFIGURATION)-universal
	lipo -create ios/AirTestFairy/build/$(CONFIGURATION)-iphoneos/libAirTestFairy.a ios/AirTestFairy/build/$(CONFIGURATION)-iphonesimulator/libAirTestFairy.a -output ios/build/$(CONFIGURATION)-universal/libAirTestFairy.a
	mkdir -p build/ios
	cp -f ios/build/$(CONFIGURATION)-universal/libAirTestFairy.a build/ios/libAirTestFairy.a

build/AirTestFairy.swc: build/ios/libAirTestFairy.a
	bin/bin/compc -source-path flex/AirTestFairy/src -output build/AirTestFairy.swc -swf-version=14 -external-library-path+=bin/frameworks/libs/air/airglobal.swc -include-classes com.testfairy.AirTestFairy

build/AirTestFairy.ane: bin/bin/adt build/AirTestFairy.swc
	mkdir -p build/ios
	mkdir -p build/default
	unzip -o -d build build/AirTestFairy.swc library.swf
	cp -f build/library.swf build/ios/library.swf
	cp -f build/library.swf build/default/library.swf
	cp -f flex/AirTestFairy/src/com/testfairy/extension.xml build/extension.xml
	cp -f flex/AirTestFairy/src/com/testfairy/platformoptions.xml build/platformoptions.xml
	bin/bin/adt -package -target ane build/AirTestFairy.ane build/extension.xml -swc build/AirTestFairy.swc -platform iPhone-ARM -C build/ios . -platformoptions build/platformoptions.xml -platform default -C build/default .

clean:
	-rm -rf build
