#!/bin/bash
# Simple utility commands
# By Artx/Stayn <artx4dev@gmail.com>

# Enter the current working kernel source
function cdsource() {
BACK=$(pwd)
cd $P
}
export -f cdsource; log -f cdsource $KBELOG
# Back
function back() {
cd $BACK
BACK=.
}
export -f back; log -f back $KBELOG

# Copy the Kernel binary to a specified path
function cpkernel() {
if [ "$1" = "" ]; then
  echo "Usage: cpkernel <path> (Copy your kernel to a specified path)"
fi
if [ ! -d $1 ]; then
  echo -e "$RED$BLD   Invalid path$RATT"
  return 1
fi
KER=$VARIANT1
if [ "$ARCH" = "arm" ] && [ -f $ZI$KER ]; then
    echo -e "$WHITE   Arch: arm"
    cp $ZI/$KER $1/zImage
    echo -e "   Kernel for $KER copied to ($1) named 'zImage'"
  elif [ "$ARCH" = "arm64" ] && [ -f $ZI$KER.gz-dtb ]; then
    echo -e "$WHITE   Arch: arm64"
    cp $ZI/$KER.gz-dtb $1/Image.gz-dtb
    echo -e "   Kernel for $KER copied to ($1) named 'Image.gz-dtb'"
  elif [ "$ARCH" = "arm64" ] && [ -f $ZI$KER.gz ]; then
    echo -e "$WHITE   Arch: arm64"
    cp $ZI/$KER.gz $1/Image.gz
    echo -e "   Kernel for $KER copied to ($1) named 'Image.gz'"
  elif [ "$ARCH" = "arm64" ] && [ -f $ZI$KER ]; then
    echo -e "$WHITE   Arch: arm64"
    cp $ZI/$KER $1/Image
    echo -e "   Kernel for $KER copied to ($1) named 'Image'"
 fi
}
export -f cpkernel; log -f cpkernel $KBELOG

# Clear the current working kernel source
function clrsource() {
BACK=$(pwd)
cd $P
make clean
cd $BACK
unset BACK
}
export -f clrsource; log -f clrsource $KBELOG

# Clear Logs
function rmlogs() {
rm $LOGF/*
echo -e "$WHITE   Logs files removed$RATT"
}

