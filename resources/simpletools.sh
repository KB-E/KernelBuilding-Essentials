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

function theme() {
if [ "$1" = "" ]; then
echo "Usage: theme <number>"
echo "             1 = Blue"
echo "             2 = Red"
echo "             3 = Yellow"
echo "             4 = Magenta"
echo "             5 = Black"
echo "             6 = Cyan"
echo "             7 = White"
echo "             8 = Green" 
return 1
fi

COLORF=$CDF/resources/other/colors.sh
CURTHEME="$(grep THEME $COLORF | cut -d '=' -f2)"
case $1 in
     "1") sed -i "s/THEME=$CURTHEME/THEME=\$BLUE/g" $COLORF; echo "KB-E Theme set to Blue" ;;
     "2") sed -i "s/THEME=$CURTHEME/THEME=\$RED/g" $COLORF; echo "KB-E Theme set to Red" ;;
     "3") sed -i "s/THEME=$CURTHEME/THEME=\$YELLOW/g" $COLORF; echo "KB-E Theme set to Yellow" ;;
     "4") sed -i "s/THEME=$CURTHEME/THEME=\$MAGENTA/g" $COLORF; echo "KB-E Theme set to Magenta" ;;
     "5") sed -i "s/THEME=$CURTHEME/THEME=\$BLACK/g" $COLORF; echo "KB-E Theme set to Black" ;;
     "6") sed -i "s/THEME=$CURTHEME/THEME=\$CYAN/g" $COLORF; echo "KB-E Theme set to Cyan" ;;
     "7") sed -i "s/THEME=$CURTHEME/THEME=\$WHITE/g" $COLORF; echo "KB-E Theme set to White" ;;
     "8") sed -i "s/THEME=$CURTHEME/THEME=\$GREEN/g" $COLORF; echo "KB-E Theme set to Green" ;;
esac
source $CDF/resources/other/colors.sh
}

function backupdef () {
if [ ! -d $CDF/backup ]; then
  mkdir $CDF/backup
fi
if [ ! -d $CDF/backup/$KERNELNAME ]; then
  mkdir $CDF/backup/$KERNELNAME
fi
cp $P/arch/$ARCH/configs/$DEFCONFIG1 $CDF/backup/$KERNELNAME/$DEFCONFIG1
echo "BackupDef: Done, located at $CDF/backup/$KERNELNAME/$DEFCONFIG"
}

function restoredef () {
if [ ! -f $CDF/backup/$KERNELNAME/$DEFCONFIG1 ]; then
  echo "RestoreDef: Error, no defconfig backup found for $KERNELNAME"
else
  cp $CDF/backup/$KERNELNAME/$DEFCONFIG1 $P/arch/$ARCH/configs/$DEFCONFIG1
  echo "RestoreDef: Done, restored $KERNELNAME defconfig"
fi
}

