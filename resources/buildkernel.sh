#!/bin/bash

# Kernel building script methods
# By Artx/Stayn <jesusgabriel.91@gmail.com>

function buildkernel() {
  unset KBUILDFAILED
  log -t "BuildKernel: Checking CrossCompiler" $KBELOG
  checkcc &> /dev/null
  log -t "BuildKernel: Done" $KBELOG
  echo -ne "$THEME$BLD"
  echo -e "   _  __                 _ "
  echo -e "  | |/ /___ _ _ _ _  ___| |  "
  echo -e "  | ' </ -_) '_| ' \/ -_) |     "
  echo -e "  |_-|_\___|_| |_||_\___|_| "
  echo " "
  echo " "
  echo -e "$THEME$BLD - $KERNELNAME Kernel Building Script ($VARIANT) ($ARCH)$RATT"
  echo -e "$WHITE   Version: $VERSION for $TARGETANDROID ROM's $RATT$WHITE"
  echo " "
  if [ "$CERROR" = 1 ]; then # This exported variable means that the CrossCompiler
                             # were not found and we cannot compile the kernel
    echo -e "$RED - There was an error getting the CrossCompiler path, exiting...$RATT"
    echo " "; log -t "BuildKernel: There was an error getting the CrossCompiler, exiting..." $KBELOG
    return 1
  fi

  # Enter in the kernel source
  if [ -d $P ]; then # P = Path for Kernel defined by the user
                     # in the process or defaultsettings.sh
    cd $P
    echo -e "$THEME$BLD   Entered in $WHITE'$P' $THEME$BLDSucessfully"
    echo " "; log -t "BuildKernel: Entered in '$P'" $KBELOG
  else # If it doesnt exist it means that we don't have nothing to do
    echo -e "$RED   Path doesn't exist!"; log -t "BuildKernel: Source path '$P' doesnt exist, exiting..." $KBELOG
    echo -e "$RED - Build canceled$RATT"
    echo " "
    return 1
  fi

  # Export necessary things
  export KCONFIG_NOTIMESTAMP=true
  export ARCH=$ARCH
  log -t "BuildKernel: Exported ARCH=$ARCH" $KBELOG
  export SUB_ARCH=$ARCH;
  #echo -e "$WHITE   Exported $ARCH"  # If the program succeed at this step, this means
  export CROSS_COMPILE=$CROSSCOMPILE  # that we can start compiling the kernel!
  log -t "BuildKernel: Exported CROSS_COMPILE=$CROSSCOMPILE" $KBELOG
  #echo -e "   Exported $CROSSCOMPILE"

  # Create out folders for this device
  if [ ! -d $KOUT ]; then
    mkdir $KOUT
  fi

  #Start Building Process
  if [ "$CLR" = "1" ]; then make clean; log -t "BuildKernel: Source cleaned" $KBELOG; echo " "; fi # Clean Kernel source
  # To avoid a false sucessfull build
  rm $P/arch/arm/boot/zImage &> /dev/null
  rm $P/arch/arm/boot/Image.gz-dtb &> /dev/null
  rm $P/arch/arm/boot/Image &> /dev/null
  rm $P/arch/arm/boot/Image.gz &> /dev/null
  # ---------------------------------

  # Get config file
  if [ ! -f $P/.config ]; then
    cp $P/arch/$ARCH/configs/$DEFCONFIG $P/.config; log -t "BuildKernel: Copied defcofig to '$P/.config'" $KBELOG
  fi

  # Load defconfig
  echo -ne "$WHITE$BLD   Loading Defconfig for $VARIANT...$RATT$THEME$BLD"
  if [ "$ARCH" = "arm" ]; then
    make ARCH=arm $DEFCONFIG &> $LOGF/buildkernel_log.txt
  elif [ "$ARCH" = "arm64" ]; then
    make ARCH=arm64 $DEFCONFIG &> $LOGF/buildkernel64_log.txt
  fi
  . $P/.config
  echo -e " Done"
  echo " "; log -t "BuildKernel: Loaded '$DEFCONFIG' defconfig" $KBELOG
  # -----------------------

  # Get the number of CPU Cores
  JOBS=$(grep -c ^processor /proc/cpuinfo); log -t "BuildKernel: Number of Cores=$JOBS" $KBELOG
  # Start compiling kernel
  echo -e "$THEME$BLD   Compiling Kernel using up to $JOBS cores...  $WHITE(Don't panic if it takes some time)$RATT$WHITE"
  echo " "
  log -t "BuildKernel: Starting '$KERNELNAME' kernel build (def: $DEFCONFIG | arch=$ARCH)" $KBELOG
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
      log -t "BuildKernel: Error: No kernel built found, compiling process failed" $KBELOG
    fi
  fi
  if [ $ARCH = "arm64" ]; then
    if [ -f $P/arch/arm64/boot/Image.gz-dtb ] || [ -f $P/arch/arm64/boot/Image.gz ] || [ -f $P/arch/arm64/boot/Image ]; then
      echo -e "$WHITE   Kernel Found..."; log -t "BuildKernel: Kernel build process done successfully" $KBELOG
    else
      export KFAIL="1"
      readlog
      log -t "BuildKernel: Error: No kernel built found, compiling process failed" $KBELOG
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
    log -t "BuildKernel: Build failed, exiting..." $KBELOG
    return 1
  fi

  # Move the Kernel to out/Images
  while true
  do
    if [ $ARCH = arm ]; then
      KFNAME="$VARIANT"
      cp $P/arch/arm/boot/zImage $KOUT/$KFNAME; log -t "BuildKernel: zImage found, copying to $ZI with name '$KFNAME'" $KBELOG
      break
    elif [ $ARCH = arm64 ] && [ -f $P/arch/arm64/boot/Image.gz-dtb ]; then
      KFNAME="$VARIANT.gz-dtb"
      cp $P/arch/arm64/boot/Image.gz-dtb $KOUT/$KFNAME; log -t "BuildKernel: Image.gz-dtb found, copying to $ZI with name '$KFNAME'" $KBELOG
      break
    elif [ $ARCH = arm64 ] && [ -f $P/arch/arm64/boot/Image.gz ]; then
      KFNAME="$VARIANT.gz"
      cp $P/arch/arm64/boot/Image $KOUT/$KFNAME; log -t "BuildKernel: Image.gz found, copying to $ZI with name '$KFNAME'" $KBELOG
      break
    elif [ $ARCH = arm64 ] && [ -f $P/arch/arm64/boot/Image ]; then
      KFNAME="$VARIANT"
      cp $P/arch/arm64/boot/Image $KOUT/$KFNAME; log -t "BuildKernel: Image found, copying to $ZI with name '$KFNAME'" $KBELOG
      break
    fi
  done
  echo -e "$THEME$BLD   New Kernel ($KFNAME) Copied to$WHITE '$KOUT'"
  echo " "
  echo -e "$WHITE   Kernel for $VARIANT...$THEME$BLD Done$RATT"
  echo " "; log -t "BuildKernel: All done" $KBELOG
}

function readlog() {
if [ "$ARCH" = "arm" ]; then
    if [ "$KDEBUG" != "1" ]; then
        echo " "
        echo -e "$RED$BLD ## Build for $VARIANT Failed ## $WHITE"
        echo " " &>> $LOGF/buildkernel_log.txt
        echo "KERNEL BUILDING FAILED" &>> $LOGF/buildkernel_log.txt
        read -p "Read building log? [y/n]: " READBL  # Prompt the user to see the failed
        if [ $READBL = y ] || [ $READBL = y ]; then  # kernel build log
          log -t "ReadLog: Opening kernel build log to user" $KBELOG
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
          log -t "ReadLog: Opening kernel build log to user" $KBELOG
          nano $LOGF/buildkernel64_log.txt
          unset READBL
        fi
    fi
fi
}
export -f buildkernel; log -f buildkernel $KBELOG
export -f readlog; log -f readlog $KBELOG
# Define kernel out path
KOUT=$KDPATH/out/kernel
