#!/bin/sh
BUILD_DIR="build/"
if [ -d "$BUILD_DIR" ]; then
        sudo rm -r build
fi

red="\e[0;91m"
blue="\e[0;94m"
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
white="\e[0;97m"
bold="\e[1m"
uline="\e[4m"
reset="\e[0m"

function title {
	PREFIX="\n$bold-----"
	SUFFIX="--$reset"
	echo -e "$PREFIX $1 $SUFFIX"
}

function print_execution {
	if $1; then
		echo -e "$green_bg$bold-- $1$reset"
	else
		echo -e "$red_bg$bold-- Operation failed for: $1$reset"
	fi
}

# Set environment variables
# ---------------------------------------
title "Setting environment variables"
export ARCH=x86_64
export VERSION="devel"

# Meson/ninja build
# ---------------------------------------
title "Building with meson and ninja"
print_execution "mkdir build"
print_execution "meson build"
print_execution "cd build"
print_execution "ninja"

# Appdir
# ---------------------------------------
title "Preparing directories"
print_execution "mkdir -p appdir/usr/local/share/bottles"
print_execution "mkdir -p appdir/usr/bin"
print_execution "mkdir -p appdir/usr/share/glib-2.0/schemas"
print_execution "mkdir -p appdir/usr/share/applications"
print_execution "mkdir -p appdir/usr/share/metainfo"
print_execution "mkdir -p appdir/usr/share/icons"

title "Compiling and installing glib-resources"
print_execution "glib-compile-resources --sourcedir=../src/ui/ ../src/ui/bottles.gresource.xml --target=appdir/usr/local/share/bottles/bottles.gresource"


title "Copying Bottles binary"
print_execution "cp src/bottles ./appdir/usr/bin/"

title "Copying Bottles python package and remove not useful files"
print_execution "cp -a ../src appdir/usr/local/share/bottles/bottles"
print_execution "rm appdir/usr/local/share/bottles/bottles/bottles.in"
print_execution "rm appdir/usr/local/share/bottles/bottles/meson.build"

title "Copying appdata"
#cp -a ../data/com.usebottles.bottles.appdata.xml.in appdir/usr/share/metainfo/com.usebottles.bottles.appdata.xml

title "Compiling and installing translations"
cat ../po/LINGUAS | while read lang
do
	print_execution "mkdir -p appdir/usr/share/locale/$lang/LC_MESSAGES"
	print_execution "msgfmt -o appdir/usr/share/locale/$lang/LC_MESSAGES/bottles.mo ../po/$lang.po"
done

title "Copying icons"
print_execution "cp -a ../data/icons appdir/usr/share"

title "Copying and compiling gschema"
print_execution "cp ../data/com.usebottles.bottles.gschema.xml appdir/usr/share/glib-2.0/schemas/com.usebottles.bottles.gschema.xml"
print_execution "glib-compile-schemas appdir/usr/share/glib-2.0/schemas/"

title "Copying Desktop file"
print_execution "cp data/com.usebottles.bottles.desktop appdir/usr/share/applications/"

title "Copying AppRun file"
print_execution "cp -a ../AppRun appdir/AppRun"

# Appimage
# ---------------------------------------
title "Downloading linuxdeploy Appimage and setting executable"
print_execution "wget -c -nv https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
print_execution "chmod a+x linuxdeploy-x86_64.AppImage"

title "Building Bottles Appimage"
#./linuxdeploy-x86_64.AppImage --appdir appdir --icon-file=../data/icons/hicolor/scalable/apps/com.usebottles.bottles.svg --output appimage
print_execution "./linuxdeploy-x86_64.AppImage --appdir appdir  --output appimage"
