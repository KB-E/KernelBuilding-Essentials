#!/bin/bash

# Load predefined Device configuration file and work on it
# By Artx/Stayn <jesusgabriel.91@gmail.com>

auto () {
  if [ "$1" = "" ]; then
    echo " - Usage: auto <device> (--remove to remove device | --edit to edit device)"
    return 1
  fi
  if [ -f $CDF/resources/auto-devices/"$1" ] && [ "$2" = "--edit" ] || [ "$2" = "--remove" ]; then
    if [ "$2" = "--edit" ]; then
      nano $CDF/resources/auto-devices/$1
    elif [ "$2" = "--remove" ]; then
      rm $CDF/resources/auto-devices/$1
      echo -e "$RED$BLD - Removed $1 Device"
    fi
  elif [ ! -f $CDF/resources/auto-devices/"$1" ]; then
    echo -e " "
    echo -e "$THEME$BLD - This device doesn't has a pre-configured info file in the program$WHITE"
    read -p "   Configure a information file for $1? [y/n]: " DPF
    if [ "$DPF" = "y" ] || [ "$DPF" = "Y" ]; then
      export DEVICE=$1
      export CURF=$(pwd)
      echo " "
      . $CDF/resources/variables.sh
      . $CDF/resources/other/checkfolders.sh
      echo " "
      echo -ne "$THEME$BLD   Checking folders..."
      checkfolders &> /dev/null
      echo -e "$WHITE Done"
      . $CDF/resources/writesettings.sh
      unset DEVICE
    fi
  elif [ -f $CDF/resources/auto-devices/"$1" ]; then #|| [ $2 = $(sed -n '2p' < $1 | cut -d '=' -f3) ; then
    echo -e " "
    echo -ne "$THEME$BLD - Exporting $1 configuration file information...$WHITE"
    . $CDF/resources/auto-devices/$1 &> /dev/null
    echo -e " Done"
    echo " "
    echo -e "$THEME$BLD -$WHITE Initializing $THEME$BLD$1$WHITE Build all process"
    sleep 0.5
    # Current Directory
    export CURF=$(pwd)
    # Load necessary files
    echo " "
    . $CDF/resources/resources/paths.sh
    . $CDF/resources/megaconfig.sh
    . $CDF/resources/scripts/buildkernel.sh
    . $CDF/resources/scripts/makeanykernel.sh
    . $CDF/resources/scripts/makedtb.sh
    . $CDF/resources/scripts/upload.sh
    . $CDF/resources/other/folders.sh
    . $CDF/resources/programtools.sh
    echo " "
    echo -ne "$THEME$BLD   Checking environment folders..."
    checkfolders &> /dev/null
    echo -e "$WHITE Done"
    # Start working
    buildkernel
    build_dtb
    make_anykernel
    if [ "$UIM" = y ] || [ "$UIM" = Y ]; then
      megaupload
    fi
    echo -e "$THEME$BLD - $1$WHITE Done!$RATT"
    # Clear Variables
    unset CURF;
  fi
  echo " "
  echo -e "$WHITE - Done$RATT"
}
