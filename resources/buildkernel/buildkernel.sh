#!/bin/bash

# Kernel building script methods
# By Artx/Stayn <jesusgabriel.91@gmail.com>

buildkernel () {
  checkcc &> /dev/null
  echo -ne "$GREEN$BLD"
  echo -e "   _  __                 _ "
  echo -e "  | |/ /___ _ _ _ _  ___| |  "
  echo -e "  | ' </ -_) '_| ' \/ -_) |     "
  echo -e "  |_-|\\___|_| |_||_\___|_| "
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
  export KCONFIG_NOTIMESTAMP=true
  export ARCH=$ARCH                   # If the program succed at this step, this means
  export SUB_ARCH=$ARCH;
  #echo -e "$WHITE   Exported $ARCH"
  export CROSS_COMPILE=$CROSSCOMPILE  # that we can start compiling the kernel!
  #echo -e "   Exported $CROSSCOMPILE"

  #Start Building Process
  if [ "$CLR" = "1" ]; then make clean; echo " "; fi # Clean Kernel source
  # To avoid a false sucessfull build
  rm $P/arch/arm/boot/zImage &> /dev/null
  rm $P/arch/arm/boot/Image.gz-dtb &> /dev/null
  rm $P/arch/arm/boot/Image &> /dev/null
  rm $P/arch/arm/boot/Image.gz &> /dev/null
  # ---------------------------------

  # Get config file
  if [ ! -f $P/.config ]; then
    cp $P/arch/$ARCH/configs/$DEFCONFIG $P/.config
  fi

  # Load defconfig
  echo -ne "$WHITE$BLD   Loading Defconfig for $VARIANT...$RATT$GREEN$BLD"
  if [ "$ARCH" = "arm" ]; then
    make ARCH=arm $DEFCONFIG &> $LOGF/buildkernel_log.txt
  elif [ "$ARCH" = "arm64" ]; then
    make ARCH=arm64 $DEFCONFIG &> $LOGF/buildkernel64_log.txt
  fi
  . $P/.config
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
  echo " "
  if [ $ARCH = "arm" ]; then
    if [ "$KDEBUG" != "1" ]; then
      make CONFIG_NO_ERROR_ON_MISMATCH=y -j$JOBS ARCH=arm &>> $LOGF/buildkernel_log.txt # Store logs
    else
      make CONFIG_NO_ERROR_ON_MISMATCH=y -j$JOBS ARCH=arm
    fi
  fi
  if [ $ARCH = "arm64" ]; then
    if [ "$KDEBUG" != "1" ]; then
      make -j$JOBS ARCH=arm64 &>> $LOGF/buildkernel64_log.txt # Store logs
    else
      make -j$JOBS ARCH=arm64
   fi
  fi
  echo "   Done"
  echo " "

  # Verify if the kernel were built
  if [ $ARCH = "arm" ]; then
    if [ ! -f $P/arch/arm/boot/zImage ]; then # If theres no zImage built then there was
      export KFAIL="1"                        # an error compiling the kernel
      readlog # Asks the user to open the kernel log in KDEBUG is disabled
    fi
  fi
  if [ $ARCH = "arm64" ]; then
    if [ -f $P/arch/arm64/boot/Image.gz-dtb ] || [ -f $P/arch/arm64/boot/Image.gz ] || [ -f $P/arch/arm64/boot/Image ]; then
      echo -e "$WHITE   Kernel Found..."
    else
      export KFAIL="1"
      readlog
    fi
  fi
  
  # If KFAIL=1 then exit the script
  if [ "$KFAIL" = "1" ]; then
    echo " "
    echo -e "$RED   ## Kernel Building Failed ##$RATT"
    # Report failed build to KB-E
    export KBUILDFAILED=1
    echo " "
    unset KFAIL
    return 1
  fi

  # Move the Kernel to out/Images
  while true
  do
    if [ $ARCH = arm ]; then
      KFNAME="$VARIANT"     
      cp $P/arch/arm/boot/zImage $ZI/$KFNAME
      break
    elif [ $ARCH = arm64 ] && [ -f $P/arch/arm64/boot/Image.gz-dtb ]; then
      KFNAME="$VARIANT.gz-dtb"     
      cp $P/arch/arm64/boot/Image.gz-dtb $ZI/$KFNAME
      break
    elif [ $ARCH = arm64 ] && [ -f $P/arch/arm64/boot/Image.gz ]; then 
      KFNAME="$VARIANT.gz"     
      cp $P/arch/arm64/boot/Image $ZI/$KFNAME
      break
    elif [ $ARCH = arm64 ] && [ -f $P/arch/arm64/boot/Image ]; then  
      KFNAME="$VARIANT"        
      cp $P/arch/arm64/boot/Image $ZI/$KFNAME
      break
    fi
  done
  echo -e "$GREEN$BLD   New Kernel ($KFNAME) Copied to$WHITE '$ZI'"
  echo " "
  echo -e "$WHITE   Kernel for $VARIANT...$GREEN$BLD Done$RATT"
  echo " "
  cd $CDF
}

readlog () {
if [ "$ARCH" = "arm" ]; then
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
if [ "$ARCH" = "arm64" ]; then
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
}
