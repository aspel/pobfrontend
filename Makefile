DIR := ${CURDIR}
SHELL := /bin/bash
OS_NAME := $(shell uname -s)
.ONESHELL: # Applies to every targets in the file!
.SHELLFLAGS := -o pipefail -eucx

# Build based on OS name
all: $(OS_NAME)

Darwin: pob
	LDFLAGS='-L/usr/local/opt/qt@5/lib' \
	CPPFLAGS='-I/usr/local/opt/qt@5/include' \
	PKG_CONFIG_PATH='/usr/local/opt/qt@5/lib/pkgconfig' \
	meson setup --buildtype=release --prefix=${DIR}/PathOfBuilding.app --bindir=Contents/MacOS build
	meson compile -C build
	meson install -C build
	/usr/local/opt/qt@5/bin/macdeployqt ${DIR}/PathOfBuilding.app
	cp ${DIR}/Info.plist.sh ${DIR}/PathOfBuilding.app/Contents/Info.plist
	echo "Finished $(OS_NAME)"

Linux: pob
	meson setup --buildtype=release build
	meson compile -C build
	mv build/PathOfBuilding PathOfBuilding/
	echo "Finished $(OS_NAME)"

pob: clear tools_$(OS_NAME) load_pob luacurl
	pushd PathOfBuilding && \
	unzip runtime-win32.zip lua/xml.lua lua/base64.lua lua/sha1.lua && \
	mv lua/*.lua . && \
	rmdir lua && \
	cp ../lcurl.so . && \
	mv src/* . && \
	rmdir src && \
	popd

load_pob:
	git clone --branch dev --single-branch --depth 1 https://github.com/PathOfBuildingCommunity/PathOfBuilding.git PathOfBuilding && \
	pushd PathOfBuilding && \
	rm -rf .git && \
	popd

luacurl:
	git clone --branch v0.3.13 --single-branch --depth 1 https://github.com/Lua-cURL/Lua-cURLv3.git Lua-cURLv3 && \
	pushd Lua-cURLv3 && \
	sed -i -e 's/\?= lua$$/\?= luajit/' Makefile && \
	make && \
	mv lcurl.so ../lcurl.so && \
	popd

clear:
	rm -rf PathOfBuilding PathOfBuilding.app Lua-cURLv3 lcurl.so build

tools_Darwin:
	brew install jq qt5 luajit zlib meson curl dylibbundler

tools_Linux:
	sudo apt update && sudo apt -y install qtbase5-dev qt5-qmake \
	qtcreator luajit libluajit-5.1-dev zlib1g zlib1g-dev meson \
	xvfb build-essential ninja-build x11-apps imagemagick libcurl4-openssl-dev