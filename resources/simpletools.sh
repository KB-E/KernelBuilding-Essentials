#!/bin/bash
# Simple utility commands
# By Artx/Stayn <artx4dev@gmail.com>

# Copy the DTB Image to a specified path
function cpdtb() {
if [ "$1" = "" ]; then
  echo "Usage: cpdtb <path> <name> (Copy your DTB to a specified path)"
  return 1
fi
if [ ! -d $1 ]; then echo -e "$RED$BLD   Invalid path$RATT"; return 1; fi
if [ -z "$2" ]; then
  # Use default name
  cp $DTOUT/$device_variant $1/dt.img
  echo -e "   DTB for $VARIANT copied to ($1) named 'dt.img'"
else
  # Use name provided by user
  cp $DTOUT/$device_variant $1/$2
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
cd $kernel_source
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

function kbe_themer() {
if [ "$1" = "" ]; then
echo " "; echo -e "$THEME$BLD   Usage:$WHITE theme <number>"
echo -e "$BLUE$BLD                1 =$WHITE Blue"
echo -e "$RED$BLD                2 =$WHITE Red"
echo -e "$YELLOW$BLD                3 =$WHITE Yellow"
echo -e "$MAGENTA$BLD                4 =$WHITE Magenta"
echo -e "$BLACK$BLD                5 =$WHITE Black"
echo -e "$CYAN$BLD                6 =$WHITE Cyan"
echo -e "$WHITE$BLD                7 =$WHITE White"
echo -e "$GREEN$BLD                8 =$WHITE Green$RATT"; echo " "
return 1
fi

COLORF=$kbe_path/resources/other/colors.sh
CURTHEME="$(grep THEME $COLORF | cut -d '=' -f2)"
echo " "
case $1 in
     "1") sed -i "s/THEME=$CURTHEME/THEME=\$BLUE/g" $COLORF; echo -e "   KB-E Theme set to$BLUE$BLD Blue" ;;
     "2") sed -i "s/THEME=$CURTHEME/THEME=\$RED/g" $COLORF; echo -e "   KB-E Theme set to$RED$BLD Red" ;;
     "3") sed -i "s/THEME=$CURTHEME/THEME=\$YELLOW/g" $COLORF; echo -e "   KB-E Theme set to$YELLOW$BLD Yellow" ;;
     "4") sed -i "s/THEME=$CURTHEME/THEME=\$MAGENTA/g" $COLORF; echo -e "   KB-E Theme set to$MAGENTA$BLD Magenta" ;;
     "5") sed -i "s/THEME=$CURTHEME/THEME=\$BLACK/g" $COLORF; echo -e "   KB-E Theme set to$BLACK$BLD Black" ;; 
     "6") sed -i "s/THEME=$CURTHEME/THEME=\$CYAN/g" $COLORF; echo -e "   KB-E Theme set to$CYAN$BLD Cyan" ;;
     "7") sed -i "s/THEME=$CURTHEME/THEME=\$WHITE/g" $COLORF; echo -e "   KB-E Theme set to$WHITE$BLD White" ;; 
     "8") sed -i "s/THEME=$CURTHEME/THEME=\$GREEN/g" $COLORF; echo -e "   KB-E Theme set to$GREEN$BLD Green" ;;
       *) echo -e "$RED$BLD   KB-E Warning:$WHITE invalid theme$RATT"
esac
source $kbe_path/resources/other/colors.sh; echo " "
}
