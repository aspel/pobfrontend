DIR := ${CURDIR}
SHELL := /bin/bash
OS_NAME := $(shell uname -s)
OS_ARCH := $(shell uname -m)
OS_ALL := ${OS_NAME}_${OS_ARCH}
.ONESHELL: # Applies to every targets in the file!
.SHELLFLAGS := -o pipefail -eucx

# Build based on OS name
all: $(OS_ALL)

Darwin_arm64: pob
	LDFLAGS='-L/opt/homebrew/opt/qt@5/lib' \
	CPPFLAGS='-I/opt/homebrew/opt/qt@5/include' \
	PKG_CONFIG_PATH='/opt/homebrew/opt/qt@5/lib/pkgconfig' \
	meson setup --buildtype=release --prefix=${DIR}/PathOfBuilding.app --bindir=Contents/MacOS build
	meson compile -C build
	meson install -C build
	/opt/homebrew/opt/qt@5/bin/macdeployqt ${DIR}/PathOfBuilding.app -verbose=2
	echo "Finished $(OS_NAME)"

Darwin_x86_64: pob
	LDFLAGS='-L/usr/local/opt/qt@5/lib' \
	CPPFLAGS='-I/usr/local/opt/qt@5/include' \
	PKG_CONFIG_PATH='/usr/local/opt/qt@5/lib/pkgconfig' \
	meson setup --buildtype=release --prefix=${DIR}/PathOfBuilding.app --bindir=Contents/MacOS build
	meson compile -C build
	meson install -C build
	/usr/local/opt/qt@5/bin/macdeployqt ${DIR}/PathOfBuilding.app -verbose=2
	echo "Finished $(OS_NAME)"

Linux_x86_64: pob
	meson setup --buildtype=release --prefix=${DIR}/linux --bindir='' build
	meson compile -C build
	meson install -C build
	echo "Finished $(OS_NAME)"

# ARM64 Linux runners commonly report uname -m as aarch64.
Linux_aarch64: Linux_x86_64
Linux_arm64: Linux_x86_64

pob: clear tools_$(OS_NAME) load_pob luacurl
	pushd PathOfBuilding && \
	unzip runtime-win32.zip 'lua/*' && \
	cp -R lua/. . && \
	rm -rf lua && \
	LJ_VER=$$(luajit -e 'print(_VERSION:match("%d+%.%d+"))') && \
	MOD_SO=$$(find "$${HOME}/.luarocks/lib/lua/$$LJ_VER" /usr/local/lib/lua/$$LJ_VER /opt/homebrew/lib/lua/$$LJ_VER -maxdepth 1 -type f -name 'lua-utf8.so' 2>/dev/null | head -n 1 || true) && \
	if [ -n "$$MOD_SO" ]; then cp "$$MOD_SO" .; fi && \
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
	brew install jq qt@5 luajit zlib meson curl dylibbundler luarocks
	LJ_VER=$$(luajit -e 'print(_VERSION:match("%d+%.%d+"))'); \
	luajit -e 'require("lua-utf8")' || luarocks --lua-version=$$LJ_VER install luautf8

tools_Linux:
	sudo apt update && sudo apt -y install qtbase5-dev qt5-qmake \
	luajit libluajit-5.1-dev zlib1g zlib1g-dev meson luarocks \
	xvfb build-essential ninja-build x11-apps imagemagick libcurl4-openssl-dev
	LJ_VER=$$(luajit -e 'print(_VERSION:match("%d+%.%d+"))'); \
	luajit -e 'require("lua-utf8")' || sudo luarocks --lua-version=$$LJ_VER install luautf8
