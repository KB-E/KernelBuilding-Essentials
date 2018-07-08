# Load predefined Device configuration file and work on it
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Function to clear KB-E Environment
kbeclear () {
echo -e "$GREEN$BLD - Performing a Cleaning...$WHITE"
if [ -f $CDF/defaultsettings.sh ]; then
  rm $CDF/defaultsettings.sh
fi
if [ -d $CDF/resources/crosscompiler/ ]; then
  rm -rf $CDF/resources/crosscompiler/
fi
if [ -d $CDF/out/ ]; then
  rm -rf $CDF/out/
fi
if [ -d $CDF/resources/logs/ ]; then
  rm -rf $CDF/resources/logs/
fi
if [ -f $CDF/resources/other/firstrun ]; then
  rm $CDF/resources/other/firstrun
fi
#if [ -d $CDF/source/ ] && [ ! -d ../source ]; then
#  mv $CDF/source/ ../
#fi
if [ -f $CDF/resources/other/variants.sh ]; then
  rm $CDF/resources/other/variants.sh
fi
echo -e "   Done$RATT"
}

auto () {
  if [ "$1" = "" ]; then
    echo " - Usage: auto <device> (--remove to remove device | --edit to edit device)"
    return 1
  fi
  if [ -f $CDF/resources/devices/"$1" ] && [ "$2" = "--edit" ] || [ "$2" = "--remove" ]; then
    if [ "$2" = "--edit" ]; then
      nano $CDF/resources/devices/$1
    elif [ "$2" = "--remove" ]; then
      rm $CDF/resources/devices/$1
      echo -e "$RED$BLD - Removed $1 Device"
    fi
  elif [ ! -f $CDF/resources/devices/"$1" ]; then
    echo -e " "
    echo -e "$GREEN$BLD - This device doesn't has a pre-configured info file in the program$WHITE"
    read -p "   Configure a information file for $1? [y/n]: " DPF
    if [ "$DPF" = "y" ] || [ "$DPF" = "Y" ]; then
      export DEVICE=$1
      export CURF=$(pwd)
      echo " "
      . $CDF/resources/paths.sh
      . $CDF/resources/megaconfig.sh
      . $CDF/resources/other/folders.sh
      echo " "
      echo -ne "$GREEN$BLD   Checking folders..."
      checkfolders &> /dev/null
      echo -e "$WHITE Done"
      . $CDF/resources/writesettings.sh
      unset DEVICE
    fi
  elif [ -f $CDF/resources/devices/"$1" ]; then #|| [ $2 = $(sed -n '2p' < $1 | cut -d '=' -f3) ; then
    echo -e " "
    echo -ne "$GREEN$BLD - Exporting $1 configuration file information...$WHITE"
    . $CDF/resources/devices/$1 &> /dev/null
    echo -e " Done"
    echo " "
    echo -e "$GREEN$BLD -$WHITE Initializing $GREEN$BLD$1$WHITE Build all process"
    sleep 0.5
    # Current Directory
    export CURF=$(pwd)
    # Load necessary files
    echo " "
    . $CDF/resources/paths.sh
    . $CDF/resources/megaconfig.sh
    . $CDF/resources/buildtools.sh
    . $CDF/scripts/buildkernel.sh
    . $CDF/scripts/makeanykernel.sh
    . $CDF/scripts/makedtb.sh
    . $CDF/scripts/upload.sh
    . $CDF/resources/other/folders.sh
    . $CDF/resources/setuptools.sh
    echo " "
    echo -ne "$GREEN$BLD   Checking environment folders..."
    checkfolders &> /dev/null
    echo -e "$WHITE Done"
    # Start working
    buildkernel
    build_dtb
    make_anykernel
    if [ "$UIM" = y ] || [ "$UIM" = Y ]; then
      megaupload
    fi
    echo -e "$GREEN$BLD - $1$WHITE Done!$RATT"
    # Clear Variables
    unset CURF;
  fi
  echo " "
  echo -e "$WHITE - Done$RATT"
}
