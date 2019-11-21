#!/bin/bash

# Kernel building script methods
# By Artx/Stayn <jesusgabriel.91@gmail.com>

function buildkernel() {
  unset kernel_build_failed
  kbelog -t "BuildKernel: Checking CrossCompiler"
  check_toolchain
  checkcc &> /dev/null; echo " "
  echo -e "$WHITE$BLD  ------------------------------------"
  echo -e "$THEME$BLD              Build Kernel            "
  echo -e "$WHITE$BLD  ------------------------------------"
  echo " "
  echo -e "$THEME$BLD   Kernel    =$WHITE $kernel_name$THEME$BLD"
  echo -e "$THEME$BLD   Device    =$WHITE $device_variant"
  if [ "$cc_available" = "false" ]; then # This exported variable means that the CrossCompiler
                               # were not found and we cannot compile the kernel
    echo -e "$RED   There was an error getting the CrossCompiler, exiting...$RATT"
    echo " "; kbelog -t "BuildKernel: There was an error getting the CrossCompiler, exiting...";
    unset cc_available; return 1
  fi

  # Enter in the kernel source if it exist
  if [ -d $kernel_source ]; then
    cd $kernel_source; kbelog -t "BuildKernel: Entered in '$kernel_source'"
  else # If it doesnt exist it means that we have nothing to do
    echo -e "$RED   Path doesn't exist!"; echo -e "$RED - Build canceled$RATT"
    kbelog -t "BuildKernel: Source path '$kernel_source' doesnt exist, exiting..."
    echo " "; return 1
  fi

  # Export necessary things
  export ARCH=$kernel_arch; kbelog -t "BuildKernel: Exported ARCH=$kernel_arch"
  export SUB_ARCH=$kernel_arch; kbelog -t "BuildKernel: Exported SUB_ARCH=$kernel_arch"
  export CROSS_COMPILE=$kernel_cc; kbelog -t "BuildKernel: Exported CROSS_COMPILE=$kernel_cc"
  # Export this only if kernel is arm64
  if [ "$kernel_arch" = "arm64" ]; then
    export CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32
  fi
  # Check out folder
  if [ ! -d $KOUT ]; then mkdir $KOUT; fi
  
  # ----------------------
  # Start Building Process
  # ----------------------
  
  # Clean kernel source
  if [ "$CLR" = "1" ]; then
    make clean
    echo " "; kbelog -t "BuildKernel: Source cleaned"
  fi
  # -----------------------

  # Declare array with all possible Kernel Images
  kernel_images=(zImage zImage-dtb Image.gz Image.lz4 Image.gz-dtb Image.lz4-dtb Image Image-dtb)
  # Log file
  LOGF=$kbe_path/logs/buildkernel.txt
  # To avoid a false sucessfull build
  for i in "${kernel_images[@]}"; do
    if [ -f $kernel_source/arch/$kernel_arch/boot/$i ]; then
      rm $kernel_source/arch/$kernel_arch/boot/$i
    fi
  done
  # -----------------------

  # Check if the defconfig doesn't exist
  if [ ! -f $kernel_source/arch/$kernel_arch/configs/$kernel_defconfig ]; then
    echo -e "$RED$BLD   Error:$WHITE Defconfig: '$kernel_defconfig' is missing$RATT"
    export kernel_build_failed=true; echo " "; return 1
  fi
  # -----------------------

  # Make defconfig
  echo -ne "$THEME$BLD   Defconfig =$WHITE"
  make ARCH=$kernel_arch $kernel_defconfig &> $LOGF; echo -e " Loaded"
  kbelog -t "BuildKernel: Loaded '$kernel_defconfig' defconfig"
  # -----------------------

  # Start compiling kernel
  kbelog -t "BuildKernel: Compiling kernel with $build_threads threads"
  echo -e "$THEME$BLD   Compiler  =$WHITE Using $THEME$BLD$build_threads$WHITE threads$RATT"
  echo " "; echo -e "$WHITE$BLD  ------------------------------------"; echo " "
  kbelog -t "BuildKernel: Starting $kernel_name kernel build"
  { { make -j$build_threads \
           ARCH=$kernel_arch \
  2>&1 1>&3; } | tee $kbe_path/logs/gcc-warnings.txt; } 3>&1;
  echo " ";
  # -----------------------

  # Verify if the kernel were built
  for i in "${kernel_images[@]}"; do
    if [ -f $kernel_source/arch/$kernel_arch/boot/$i ]; then
      kernel_found="true"
      break
    else
      kernel_found="false"
    fi
  done
  # -----------------------

  # If kernel_found=false then exit
  if [ "$kernel_found" = "false" ]; then
    echo -e "$WHITE$BLD  -----------------------------------"
    echo -e "$RED$BLD        Kernel Building Failed"
    echo -e "$WHITE$BLD  -----------------------------------"
    # Report failed build
    export kernel_build_failed=true; echo " "
    kbelog -t "BuildKernel: Build failed for $device_variant, exiting..."
    return 1
  fi
  # -----------------------

  # Clean kernel out folder
  for i in "${kernel_images[@]}"; do
    if [ -f $KOUT/$i ]; then
      rm $KOUT/$i
    fi
  done
  # -----------------------

  # Move the Kernel Images to the device out folder
  for i in "${kernel_images[@]}"; do
    if [ -f $kernel_source/arch/$kernel_arch/boot/$i ]; then
      cp $kernel_source/arch/$kernel_arch/boot/$i $KOUT/; kbelog -t "BuildKernel: Kernel Image '$i' found"
    fi
  done
  echo -e "$WHITE$BLD  -----------------------------------"
  echo -e "$THEME$BLD       Kernel built successfully$RATT"
  echo -e "$WHITE$BLD  -----------------------------------"
  echo " "; kbelog -t "BuildKernel: All done"
  # -----------------------

}; export -f buildkernel; kbelog -f buildkernel
KOUT=$device_kernel_path/out/kernel # Define kernel out path

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
  # For this function to work, the variable kernel_build_dtb must be set with the value
  # "1" or "0". If that variable is not set, exit this function and tell the user to load
  # a device or initialize a new one and set selected_image=none
  if [ -z "$kernel_build_dtb" ]; then
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
  if [ "$kernel_arch" = "arm" ]; then
    # Pretty much what you will find in arm is zImage and zImage-dtb
    # Decide between both of them and leave the hardest part to arm64 bellow this
    # If user enabled dtb building then priorize zImage and Image over zImage-dtb
    if [ "$kernel_build_dtb" = "true" ]; then
      if [ "$kernel_zimage" = "true" ]; then
        selected_image=zImage
      elif [ "$kernel_image" = "true" ]; then
        selected_image=Image
      elif [ "$kernel_zimage_dtb" = "true" ]; then
        selected_image=zImage-dtb
      fi
    # If user disabled dtb building then priorize zImage-dtb over zImage and Image
    elif [ "$kernel_build_dtb" = "false" ]; then
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
    if [ "$kernel_build_dtb" = "true" ]; then
      export selected_image=Image.lz4
    elif [ "$kernel_build_dtb" = "false" ]; then
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
    if [ "$kernel_build_dtb" = "true" ]; then
      if [ "$kernel_zimage" = "true" ]; then
        export selected_image=zImage
      elif [ "$kernel_image" = "true" ]; then
        export selected_image=Image
      elif [ -z "$kernel_zimage" ] && [ -z "$kernel_image" ]; then
        export selected_image=none
        echo -e "$RED$BLD   Error:$WHITE could not select a kernel image, kernel is not built$RATT"
      fi
    elif [ "$kernel_build_dtb" = "false" ]; then
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
    if [ "$kernel_build_dtb" = "true" ]; then
      export selected_image=Image.lz4
    elif [ "$kernel_build_dtb" = "false" ]; then
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
    if [ "$kernel_build_dtb" = "true" ]; then
      export selected_image=Image.gz
    elif [ "$kernel_build_dtb" = "false" ]; then
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
