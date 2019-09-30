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
  echo -e "$THEME$BLD   --------------------------$WHITE"
  echo -e "$WHITE - Kernel Building Script for $THEME$BLD$VARIANT$WHITE ($ARCH)"
  echo -e "   Kernel:$THEME$BLD $KERNELNAME$WHITE; Variant:$THEME$BLD $VARIANT$WHITE; Version:$THEME$BLD $VERSION$WHITE"
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
    log -t "BuildKernel: Entered in '$P'" $KBELOG
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
  export CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32
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
  log -t "BuildKernel: Loaded '$DEFCONFIG' defconfig" $KBELOG
  # -----------------------

  # Get the number of CPU Cores
  JOBS=$(grep -c ^processor /proc/cpuinfo); log -t "BuildKernel: Number of Cores=$JOBS" $KBELOG
  # Start compiling kernel
  echo -e "$WHITE   Compiling Kernel using up to $JOBS cores...$RATT"
  echo -e "$THEME$BLD   --------------------------$WHITE"
  echo " "
  log -t "BuildKernel: Starting '$KERNELNAME' kernel build (def: $DEFCONFIG | arch=$ARCH)" $KBELOG
  source $CDF/resources/buildkernel-assistant.sh
  echo " "
  echo -e "$THEME$BLD   --------------------------$WHITE"

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

  # Clean device out folder
  rm -rf $KOUT/*
  # Declare array with all possible Kernel Images
  kernel_images=(zImage zImage-dtb Image.gz Image.lz4 Image.gz-dtb Image.lz4-dtb Image Image-dtb)
  # Move the Kernel Images to the device out folder
  for i in "${kernel_images[@]}"; do
    if [ -f $P/arch/$ARCH/boot/$i ]; then
      cp $P/arch/$ARCH/boot/$i $KOUT/; log -t "BuildKernel: Kernel Image '$i' found" $KBELOG
    fi
  done
  echo -e "$THEME$BLD   Kernel Images copied to$WHITE '$KOUT'"
  echo -e "$WHITE   Kernel for $VARIANT...$THEME$BLD Done$RATT"
  echo -e "$THEME$BLD   --------------------------$RATT"
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

# ------------------------------------------------
# Automatically select the appropiate Kernel Image
# ------------------------------------------------
function selectimage() {
  # This script will automatically select a kernel image for
  # the device KB-E is currently working for, this script takes
  # in consideration various factors, variables and settings
  # to make the best decision possible.

  # Store all possible kernel Images
  kernel_images=(zImage zImage-dtb Image.gz Image.lz4 Image.gz-dtb Image.lz4-dtb Image Image-dtb)
  # Declare array to store found kernel images
  unset built_images; declare -a built_images
  # Unset some variables
  unset kernel_image; unset kernel_zimage; unset kernel_image_dtb; unset kernel_zimage_dtb
  unset kernel_image_gz; unset kernel_image_lz4; unset kernel_image_gz_dtb; unset kernel_image_lz4_dtb
  # For this function to work, the variable BDTB must be set with the value "1" or "0"
  # If that variable is not set, exit this function and tell the user to load a device or
  # initialize a new one and set selected_image=none
  if [ -z "$BDTB" ]; then
    echo -e "$RED$BLD   Error:$WHITE a setting is missing, reload your device or initialize a new one$RATT"
    export selected_image=none
    return 1
  fi

  # ---------
  #  Methods
  # ---------
  # For each kernel image possible, create another array containing
  # available kernel images
  for i in ${kernel_images[@]}
  do
    if [ -f $KOUT/"$i" ]; then
      built_images+=("$i")
    fi
  done
  # Now for each image available check if it exist, those images
  # that exist will be marked as true
  for i in "${built_images[@]}"
  do
    if [ "$i" = "Image" ]; then kernel_image=true; fi
    if [ "$i" = "Image.gz" ]; then kernel_image_gz=true; fi
    if [ "$i" = "Image.gz-dtb" ]; then kernel_image_gz_dtb=true; fi
    if [ "$i" = "Image.lz4" ]; then kernel_image_lz4=true; fi
    if [ "$i" = "Image.lz4-dtb" ]; then kernel_image_lz4_dtb=true; fi
    if [ "$i" = "zImage" ]; then kernel_zimage=true; fi
    if [ "$i" = "Image-dtb" ]; then kernel_image_dtb=true; fi
    if [ "$i" = "zImage-dtb" ]; then kernel_zimage_dtb=true; fi
  done

  # Make the actual decision for arm (32bits)
  # Which kernel image will be the chosen one!!??
  if [ "$ARCH" = "arm" ]; then
    # Pretty much what you will find in arm is zImage and zImage-dtb
    # Decide between both of them and leave the hardest part to arm64 bellow this
    # If user enabled dtb building then priorize zImage and Image over zImage-dtb
    if [ "$BDTB" = "1" ]; then
      if [ "$kernel_zimage" = "true" ]; then
        selected_image=zImage
      elif [ "$kernel_image" = "true" ]; then
        selected_image=Image
      elif [ "$kernel_zimage_dtb" = "true" ]; then
        selected_image=zImage-dtb
      fi
    # If user disabled dtb building then priorize zImage-dtb over zImage and Image
    elif [ "$BDTB" = "0" ]; then
      if [ "$kernel_zimage_dtb" = "true" ]; then
       export selected_image=zImage-dtb
      elif [ "$kernel_zimage" = "true" ]; then
        export selected_image=zImage
      elif [ "$kernel_image" = "true" ]; then
        export selected_image=Image
      fi
    fi
  # We're done here
  return 1
  fi

  # Get compression method(s), this is based on the existing compressed images
  # It may not be accurate if for example Image.gz is not built but Image.gz-dtb is,
  # this case would be pretty weird but I'll adress it on future updates
  if [ "$kernel_image_gz" = "true" ]; then compression_gz=true; else compression_gz=false; fi
  if [ "$kernel_image_lz4" = "true" ]; then compression_lz4=true; else compression_lz4=false; fi
  if [ -z "$kernel_image_gz" ] && [ -z "$kernel_image_lz4" ]; then compression_none=true; else compression_none=false; fi

  # Make the actual decision for arm64 (64bits), these decisions will be based on
  # the variables we've been setting, compression methods, etc... This will be
  # divided in cases, if a kernel matches one of the four cases it will enter
  # to the automatic decision process and the output will be an exported variable
  # named "selected_image" which value will be the name of the kernel image
  # selected, this can never be empty, after running this function if the kernel
  # was built successfully, a kernel image must be always chosen, if not, there is
  # something this code isn't taking in consideration. Now, the cases are:

  # Case 1: Both GZ and LZ4 compression enabled, in this case we know that
  # we have Image.gz and Image.lz4, if user wants to build DTB manually then
  # select Image.lz4 by default, if user doesnt want to build DTB manually then
  # select Image.lz4-dtb by default, if it doesnt exist, select Image.gz-dtb,
  # if those two Images with dtb appended doesnt exist then search for a
  # uncompressed kernel image with dtb appended, if that also doesn't exist then
  # select Image.lz4 by default and warn the user
  if [ "$compression_gz" = "true" ] && [ "$compression_lz4" = "true" ]; then
    echo -e "$WHITE   Your kernel source has$THEME$BLD two methods$WHITE of compression enabled..!$RATT"
    if [ "$BDTB" = "1" ]; then
      export selected_image=Image.lz4
    elif [ "$BDTB" = "0" ]; then
      if [ "$kernel_image_lz4_dtb" = "true" ]; then
        export selected_image=Image.lz4-dtb
      elif [ "$kernel_image_gz_dtb" = "true" ]; then
        export selected_image=Image.gz-dtb
      elif [ -z "$kernel_image_lz4_dtb" ] && [ -z "$kernel_image_gz_dtb" ]; then
        if [ "$kernel_image_dtb" = "true" ]; then
          export selected_image=Image-dtb
        elif [ "$kernel_zimage_dtb" = "true" ]; then
          export selected_image=zImage-dtb
        elif [ -z "$kernel_image_dtb" ] && [ -z "$kernel_zimage_dtb" ]; then
          export selected_image=Image.lz4
          echo -e "$RED$BLD   Warning:$WHITE Kernel with appended dtb not found, please build DTB manually$RATT"
        fi
      fi
    fi
  fi

  # Case 2: Both GZ and LZ4 compression disabled, in this case we know that
  # this kernel source has no compressed images, which leads to 4 available
  # options: zImage, zImage-dtb, Image and Image-dtb. if user doesnt want to
  # build DTB manually then select zImage-dtb by default, if it doesnt exist
  # then select Image-dtb, if it doesn't exist then select zImage and at last
  # resource if that also doesnt exist select Image. Because these could be
  # the only 4 possible Images for this case, if none of them exist then we
  # can be sure that the kernel building failed and warn the user.
  if [ "$compression_gz" = "false" ] && [ "$compression_lz4" = "false" ]; then

    echo -e "$WHITE   Your kernel source has$THEME$BLD no$WHITE compression methods enabled..!$RATT"$RATT
    if [ "$BDTB" = "1" ]; then
      if [ "$kernel_zimage" = "true" ]; then
        export selected_image=zImage
      elif [ "$kernel_image" = "true" ]; then
        export selected_image=Image
      elif [ -z "$kernel_zimage" ] && [ -z "$kernel_image" ]; then
        export selected_image=none
        echo -e "$RED$BLD   Error:$WHITE could not select a kernel image, kernel is not built$RATT"
      fi
    elif [ "$BDTB" = "0" ]; then
      if [ "$kernel_zimage_dtb" = "true" ]; then
        export selected_image=zImage-dtb
      elif [ "$kernel_image_dtb" = "true" ]; then
        export selected_image=Image-dtb
      elif [ "$kernel_zimage" = "true" ]; then
        export selected_image=zImage
        echo -e "$RED$BLD   Warning:$WHITE Kernel with appended dtb not found, please build DTB manually$RATT"
      elif [ "$kernel_image" = "true" ]; then
        export selected_image=Image
        echo -e "$RED$BLD   Warning:$WHITE Kernel with appended dtb not found, please build DTB manually$RATT"
      elif [ -z "$kernel_zimage" ] && [ -z "$kernel_image" ]; then
        export selected_image=none
        echo -e "$RED$BLD   Error:$WHITE could not select a kernel image, kernel is not built$RATT"
      fi
    fi
  fi

  # Case 3: We have LZ4 compression enabled, then, if user wants to build DTB manually
  # just select Image.lz4, if user don't want to build DTB manually then select
  # Image.lz4-dtb, if it doesnt exist then search for Image-dtb or zImage-dtb, if those
  # doesnt exist, then just select Image.lz4 by default and warn the user
  if [ "$compression_gz" = "false" ] && [ "$compression_lz4" = "true" ]; then
    echo -e "$WHITE   Your kernel source has$THEME$BLD lz4$WHITE compression method enabled..!$RATT"
    if [ "$BDTB" = "1" ]; then
      export selected_image=Image.lz4
    elif [ "$BDTB" = "0" ]; then
      if [ "$kernel_image_lz4_dtb" = "true" ]; then
        export selected_image=Image.lz4-dtb
      elif [ "$kernel_image_dtb" = "true" ]; then
        export selected_image=Image-dtb
      elif [ "$kernel_zimage_dtb" = "true" ]; then
        export selected_image=zImage-dtb
      elif [ -z "$kernel_image_lz4_dtb" ] && [ -z "$kernel_image_dtb" ] && [ -z "$kernel_zimage_dtb" ]; then
        echo -e "$RED$BLD   Warning:$WHITE Kernel with appended dtb not found, please build DTB manually$RATT"
        export selected_image=Image.lz4
      fi
    fi
  fi

  # Case 3: We have GZ compression enabled, then, if user wants to build DTB manually
  # just select Image.gz, if user don't want to build DTB manually then select
  # Image.gz-dtb, if it doesnt exist then search for Image-dtb or zImage-dtb, if those
  # doesnt exist, then just select Image.gz by default and warn the user
  if [ "$compression_gz" = "true" ] && [ "$compression_lz4" = "false" ]; then
    echo -e "$WHITE   Your kernel source has$THEME$BLD gz$WHITE compression method enabled..!$RATT"
    if [ "$BDTB" = "1" ]; then
      export selected_image=Image.gz
    elif [ "$BDTB" = "0" ]; then
      if [ "$kernel_image_gz_dtb" = "true" ]; then
        export selected_image=Image.gz-dtb
      elif [ "$kernel_image_dtb" = "true" ]; then
        export selected_image=Image-dtb
      elif [ "$kernel_zimage_dtb" = "true" ]; then
        export selected_image=zImage-dtb
      elif [ -z "$kernel_image_gz_dtb" ] && [ -z "$kernel_image_dtb" ] && [ -z "$kernel_zimage_dtb" ]; then
        echo -e "$RED$BLD   Warning:$WHITE Kernel with appended dtb not found, please build DTB manually$RATT"
        export selected_image=Image.gz
      fi
    fi
  fi
}
