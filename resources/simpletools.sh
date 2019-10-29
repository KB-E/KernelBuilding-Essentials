#!/bin/bash
# Simple utility commands
# By Artx/Stayn <artx4dev@gmail.com>

# Enter the current working kernel source
function cdsource() {
BACK=$(pwd)
cd $P
}
export -f cdsource; kbelog -f cdsource
# Back
function back() {
cd $BACK
BACK=.
}
export -f back; kbelog -f back

# Copy the DTB Image to a specified path
function cpdtb() {
if [ "$1" = "" ]; then
  echo "Usage: cpdtb <path> <name> (Copy your DTB to a specified path)"
  return 1
fi
if [ ! -d $1 ]; then echo -e "$RED$BLD   Invalid path$RATT"; return 1; fi
if [ -z "$2" ]; then
  # Use default name
  cp $DTOUT/$VARIANT $1/dt.img
  echo -e "   DTB for $VARIANT copied to ($1) named 'dt.img'"
else
  # Use name provided by user
  cp $DTOUT/$VARIANT $1/$2
  echo -e "   DTB for $VARIANT copied to ($1) named '$2'"
fi
}
export -f cpdtb; kbelog -f cpdtb

# Copy the Kernel binary to a specified path
function cpkernel() {
if [ "$1" = "" ]; then
  echo "Usage: cpkernel <path> <imagename> (Copy your kernel to a specified path)"
  echo "                       (optional)"
  return 1
fi
if [ ! -d $1 ]; then
  echo -e "$RED$BLD   Invalid path$RATT"
  return 1
fi
selectimage
if [ -z "$2" ]; then
  echo "BuildKernel: Automatically selected Kernel Image: $selected_image"
  cp $KOUT/$selected_image $1/
  echo "CPKernel: Copied to $1"
elif [ -f $KOUT/$2 ]; then
  echo "CPKernel: Kernel Image: $2 Exist"
  cp $KOUT/$2 $1/
  echo "CPKernel: Copied to $1"
elif [ ! -f $KOUT/$2 ]; then
  echo "Error: That kernel image doesnt exist"
fi
}
export -f cpkernel; kbelog -f cpkernel

# Clear the current working kernel source
function clrsource() {
BACK=$(pwd)
cd $P
make clean
cd $BACK
unset BACK
}
export -f clrsource; kbelog -f clrsource

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

function cdkbe () {
cd $kbe_path
}
