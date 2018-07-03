# Load predefined Device configuration file and work on it
# By Artx/Stayn <jesusgabriel.91@gmail.com>

auto () {
  if [ ! -f $CDF/resources/devices/"$1" ]; then
    echo -e " "
    echo -e "$GREEN$BLD - This device doesn't has a pre-configured info file in the program$WHITE"
    read -p "   Configure a information file for $1? [y/n]: " DPF
    if [ "$DPF" = "y" ] || [ "$DPF" = "Y" ]; then
      export DEVICE=$1
      . $CDF/resources/writesettings.sh
      unset DEVICE
    fi
  elif [ -f $CDF/resources/devices/"$1" ]; then #|| [ $2 = $(sed -n '2p' < $1 | cut -d '=' -f3) ; then
    echo -e " "
    echo -ne "$GREEN$BLD - Exporting $1 configuration file information...$WHITE"
    . $CDF/resources/devices/$1
    echo -e " Done"
    echo " "
    echo -e "$GREEN$BLD - Initializing $1 Build all process"
    sleep 0.5
    buildkernel
    build_dtb
    make_anykernel
    megaupload
    echo " "
    echo -e "$GREEN$BLD - $1 Done!$RATT"
  elif [ -f $CDF/resources/devices/"$1" ] && [ "$2" = "--reconfigure" ] || [ "$2" = "--remove" ]; then
    if [ "$2" = "--reconfigure" ]; then
      echo -e " "
      echo -e "$GREEN$BLD - Re-Configuring $1 $WHITE"
      export DEVICE=$1
      . $CDF/resources/writesettings.sh
      unset DEVICE
    elif [ "$2" = "--remove" ]; then
      rm $CDF/resources/devices/$1
      echo -e "$RED$BLD - Removed $1 Device"
    fi
  fi
}