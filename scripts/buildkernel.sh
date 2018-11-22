#!/bin/bash

# Kernel building script methods
# By Artx/Stayn <jesusgabriel.91@gmail.com>

buildkernel () {
  checkcc &> /dev/null
echo -ne "$GREEN$BLD"
echo -e "   _  __                 _ "
echo -e "  | |/ /___ _ _ _ _  ___| |  "
echo -e "  | ' </ -_) '_| ' \/ -_) |     "
echo -e "  |_|\_\___|_| |_||_\___|_| "
echo " "
echo " "
  echo -e "$GREEN$BLD - $KERNELNAME Kernel Building Script ($VARIANT) ($ARCH)$RATT"
  echo -e "$WHITE   Version: $VERSION for $TARGETANDROID ROM's $RATT$WHITE"
  echo " "
if [ "$CERROR" = 1 ]; then # This exported variable means that the CrossCompiler
                         # were not found and we cannot compile the kernel
  echo -e "$RED - There was an error getting the CrossCompiler path, exiting...$RATT"
  echo " "
  return 1
fi

# Enter in the kernel source
if [ -d $P ]; then # P = Path for Kernel defined by the user
                   # in the process or defaultsettings.sh
  cd $P
  echo -e "$GREEN$BLD   Entered in $WHITE'$P' $GREEN$BLDSucessfully"
  echo " "
else # If it doesnt exist it means that we don't have nothing to do
  echo -e "$RED   Path doesn't exist!"
  echo -e "$RED - Build canceled$RATT"
  echo " "
  return 1
fi

# Export necessary things
export ARCH=$ARCH                   # If the program succed at this step, this means
#echo -e "$WHITE   Exported $ARCH"
export CROSS_COMPILE=$CROSSCOMPILE  # that we can start compiling the kernel!
#echo -e "   Exported $CROSSCOMPILE"

#Start Building Process
if [ "$CLR" = "1" ]; then make clean; echo " "; fi # Clean Kernel source
# To avoid a false sucessfull build
rm $P/arch/arm/boot/zImage &> /dev/null
# ---------------------------------

# Load defconfig
echo -ne "$WHITE$BLD   Loading Defconfig for $VARIANT...$RATT$GREEN$BLD"
make $DEFCONFIG &> $LOGF/buildkernel_log.txt
echo -e " Done"
echo " "
# -----------------------

# Get the number of CPU Cores
JOBS=$(grep -c ^processor /proc/cpuinfo)
if [ "$BKB" = y ] || [ "$BKB" = Y ]; then
  JOBS=$(( $JOBS + 2 ))
fi
# Start compiling kernel
echo -e "$GREEN$BLD   Compiling Kernel using up to $JOBS cores...  $WHITE(Don't panic if it takes some time)$RATT$WHITE"
if [ $ARCH = arm ]; then
  if [ "$KDEBUG" != "1" ]; then 
    make CONFIG_NO_ERROR_ON_MISMATCH=y -j$JOBS &>> $LOGF/buildkernel_log.txt # Store logs
  else
    make CONFIG_NO_ERROR_ON_MISMATCH=y -j$JOBS 
  fi
elif [ $ARCH = arm64 ]; then
  if [ "$KDEBUG" != "1" ]; then 
    make -j$JOBS  &>> $LOGF/buildkernel64_log.txt # Store logs
  else
    make -j$JOBS 
  fi
fi
echo "   Done"
echo " "

# Verify if the kernel were built
KERROR=0
if [ $ARCH = arm ]; then
  if [ ! -f ./arch/arm/boot/zImage ]; then # If theres no zImage built then there was
    export KERROR=1                          # an error compiling the kernel
    if [ "$KDEBUG" != "1" ]; then
      echo " "
      echo -e "$RED$BLD ## Build for $VARIANT Failed ## $WHITE"
      echo " " &>> $LOGF/buildkernel_log.txt
      echo "KERNEL BUILDING FAILED" &>> $LOGF/buildkernel_log.txt
      read -p "Read building log? [y/n]: " READBL  # Prompt the user to see the failed
      if [ $READBL = y ] || [ $READBL = y ]; then  # kernel build log
        nano $LOGF/buildkernel_log.txt
        unset READBL
      fi
    fi
  fi
elif [ $ARCH = arm64 ]; then
  if [ ! -f ./arch/arm64/boot/Image.gz-dtb ]; then # If theres no zImage built then there was
    export KERROR=1                          # an error compiling the kernel
    if [ "$KDEBUG" != "1" ]; then
      echo " "
      echo -e "$RED$BLD ## Build for $VARIANT Failed ## $WHITE"
      echo " " &>> $LOGF/buildkernel64_log.txt
      echo "KERNEL BUILDING FAILED" &>> $LOGF/buildkernel64_log.txt
      read -p "Read building log? [y/n]: " READBL  # Prompt the user to see the failed
      if [ $READBL = y ] || [ $READBL = y ]; then  # kernel build log
        nano $LOGF/buildkernel64_log.txt
        unset READBL
      fi
    fi
  fi
fi

# If KERROR is not equal to 1 then we can proceed to
# move the kernel in their respective folders
if [ "$KERROR" != 1 ]; then
  if [ -f $ZIN/$VARIANT ]; then
    mv $ZIN/$VARIANT $ZI/$VARIANT
    echo -e "$GREEN$BLD   Moved old $VARIANT Kernel to$WHITE '$ZI'"
  fi
  if [ $ARCH = arm ]; then
    cp arch/arm/boot/zImage $ZIN/$VARIANT
  elif [ $ARCH = arm64 ]; then
    if [ -f arch/arm64/boot/Image.gz-dtb ]; then 
      cp arch/arm64/boot/Image.gz-dtb $ZIN/$VARIANT
    elif [ -f arch/arm64/boot/Image ]; then
      cp arch/arm64/boot/Image $ZIN/$VARIANT
    fi
  fi
  echo -e "$GREEN$BLD   New Kernel Copied to$WHITE '$ZIN'"
  echo " "
  echo -e "$WHITE   Kernel for $VARIANT...$GREEN$BLD Done$RATT"
  echo " "
else # Else, finish the function with a kernel building failed!
  echo " "
  echo -e "$RED   ## Kernel Building Failed ##$RATT"
  echo " "
fi
cd $CDF
}

# Done here
echo -e "$WHITE * Function 'buildkernel' Loaded$RATT"
