#!/bin/bash
# CrossCompiler Manager
# By Artx <artx4dev@gmail.com>

# Setup Google GCC
function cc_setup_gcc() {
  # Check GCC folder
  if [ ! -d $kbe_path/resources/gcc/ ]; then
    mkdir $kbe_path/resources/gcc
  fi; echo " "
  # Download and export Google GCC
  case $kernel_arch in
       "arm") # Check for arm CC
              if [ ! -f $kbe_path/resources/gcc/arm/bin/arm-linux-androideabi-gcc ]; then
                kbelog -t "RunSettings: arm CC not found, downloading...";
                echo -ne "$WHITE   Downloading$THEME$BLD arm$WHITE Google GCC$THEME$BLD...";
                git clone https://github.com/KB-E/arm-linux-androideabi-4.9 $kbe_path/resources/gcc/arm/ &> /dev/null;
                echo -e "$WHITE Done"; kbelog -t "RunSettings: Done";
              fi;
              export gcc_path32=$kbe_path/resources/gcc/arm/bin/arm-linux-androideabi- ;;

     "arm64") # Check for arm64 CC
              if [ ! -f $kbe_path/resources/gcc/arm64/bin/aarch64-linux-android-gcc ]; then
                kbelog -t "RunSettings: arm64 CC not found, downloading...";
                echo -ne "$WHITE   Downloading$THEME$BLD arm64$WHITE Google GCC$THEME$BLD...";
                git clone https://github.com/KB-E/aarch64-linux-android-4.9 $kbe_path/resources/gcc/arm64/ &> /dev/null;
                echo -e "$WHITE Done"; kbelog -t "RunSettings: Done";
              fi;
              # Check for arm CC (Needed by some arm64 kernels)
              if [ ! -f $kbe_path/resources/gcc/arm/bin/arm-linux-androideabi-gcc ]; then
                kbelog -t "RunSettings: arm CC not found, downloading...";
                echo -ne "$WHITE   Downloading$THEME$BLD arm$WHITE Google GCC$THEME$BLD...";
                git clone https://github.com/KB-E/arm-linux-androideabi-4.9 $kbe_path/resources/gcc/arm/ &> /dev/null;
                echo -e "$WHITE Done"; kbelog -t "RunSettings: Done";
              fi;
              export gcc_path64=$kbe_path/resources/gcc/arm64/bin/aarch64-linux-android-;
              export gcc_path32=$kbe_path/resources/gcc/arm/bin/arm-linux-androideabi-
  esac
}

# Setup Linaro ToolChain
function cc_setup_linaro() {
  # Linaro Information
  linaro_version="7.5.0"
  linaro_date="2019.12"
  linaro_package_arm="gcc-linaro-$linaro_version-$linaro_date-x86_64_arm-eabi"
  linaro_package_arm64="gcc-linaro-$linaro_version-$linaro_date-x86_64_aarch64-elf"
  linaro_path=$kbe_path/resources/linaro
  # Check working folders
  if [ ! -d $linaro_path ]; then
    mkdir $linaro_path
    mkdir $linaro_path/downloads
  fi
  # Clear some variables
  unset cc_arch_linaro; unset cc_setup_linaro
  # Download arm Linaro ToolChain if it doesn't exist
  # (anyways, it's needed by arm or arm64)
  if [ ! -d $linaro_path/$linaro_package_arm ]; then
    if [ ! -f $linaro_path/downloads/$linaro_package_arm.tar.xz ]; then
      # Download and setup Linaro for arm
      echo -ne "   Downloading$THEME$BLD Linaro$WHITE ToolChain$THEME$BLD (arm)..."; CURR=$(pwd); cd $linaro_path/downloads
      wget -c https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-eabi/$linaro_package_arm.tar.xz \
              --no-check-certificate \
              --quiet --show-progress
      echo -e "$WHITE Done"; cd $CURR; unset CURR
      cc_arch_linaro=arm
      cc_setup_linaro=true
    else
      cc_arch_linaro=arm
      cc_setup_linaro=true
    fi
  fi
  # Download arm64 Linaro ToolChain if it doesnt exist
  # (Only if kernel_arch=arm64)
  if [ "$kernel_arch" = "arm64" ]; then
    if [ ! -d $linaro_path/$linaro_package_arm64 ]; then
      if [ ! -f $linaro_path/downloads/$linaro_package_arm64.tar.xz ]; then
        echo -ne "   Downloading$THEME$BLD Linaro$WHITE ToolChain$THEME$BLD (arm64)..."; CURR=$(pwd); cd $linaro_path/downloads
        wget -c https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-elf/$linaro_package_arm64.tar.xz \
                --no-check-certificate \
                --quiet --show-progress
        echo -e "$WHITE Done"; cd $CURR; unset CURR
        cc_arch_linaro=arm64
        cc_setup_linaro=true
      else
        cc_arch_linaro=arm64
        cc_setup_linaro=true
      fi
    fi
  fi
  # Setup Linaro ToolChain if needed
  if [ "$cc_setup_linaro" = "true" ]; then
    if [ "$cc_arch_linaro" = "arm64" ]; then
      echo -ne "   Extracting$THEME$BLD Linaro$WHITE ToolChain$THEME$BLD (arm64)..."
      tar xf $linaro_path/downloads/$linaro_package_arm64.tar.xz -C $linaro_path
      tar xf $linaro_path/downloads/$linaro_package_arm.tar.xz -C $linaro_path
      echo -e "$WHITE Done"
    fi
    if [ "$cc_arch_linaro" = "arm" ]; then
      echo -ne "   Extracting$THEME$BLD Linaro$WHITE ToolChain$THEME$BLD (arm)..."
      tar xf $linaro_path/downloads/$linaro_package_arm.tar.xz -C $linaro_path
      echo -e "$WHITE Done"
    fi
  fi

  # Export linaro_path32 if kernel is arm
  if [ "$kernel_arch" = "arm" ]; then
    export linaro_path32=$linaro_path/$linaro_package_arm/bin/arm-eabi-
  fi
  # Export linaro_path32 and linaro_path64 if kernel is arm64
  if [ "$kernel_arch" = "arm64" ]; then
    export linaro_path32=$linaro_path/$linaro_package_arm/bin/arm-eabi-
    export linaro_path64=$linaro_path/$linaro_package_arm64/bin/aarch64-elf-
  fi
}

function cc_setup_custom() {
  # Set custom CrossCompiler
  echo " "; echo -e "$WHITE   Please, enter path to your custom CrossCompiler:"
  read -p "   Path: " custom_path
  if [ ! -f "$custom_path"gcc ]; then
    echo -e "$RED$BLD   Error:$WHITE gcc binary not found"
    unset custom_path
  else
    export custom_path
  fi
}
