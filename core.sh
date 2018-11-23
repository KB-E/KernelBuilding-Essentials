#!/bin/bash

# Main Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

if [ ! -f ./resources/other/firstrun ]; then
  echo " "
  echo -e " - Disclaimer: "
  echo " "
  echo -e "   This Software will ask for sudo to download and install required"
  echo -e "   programs and tools, also, to chmod and chown neccesary files for the"
  echo -e "   correct functioning of all the code, I'm not responsable if this"
  echo -e "   program breaks your PC (which it shouldn't be able). We'll now"
  echo -e "   proceed to the first run of this program after your authorization..."
  echo " "
  read -p " - Do you agree the above disclaimer and continue? [Y/N]: " DAG
  echo " "
  if [ "$DAG" != "y" ] && [ "$DAG" != "Y" ]; then
    return 1
  fi
  read -p "   Thanks, good luck with your builds! Press enter to continue..."
  echo " "
fi

sudo chmod 755 -R $(ls -A|grep -v 'source/*')
sudo chown -R $USER:users *

# Program Directory Path
CDF=$(pwd)

# Load Colors
. $CDF/resources/other/colors.sh

# If 'firstrun' file is missing perform a clean of this program environment
if [ ! -f $CDF/resources/other/firstrun ]; then
  echo -e "$GREEN$BLD - Perfoming a Cleaning...$WHITE"
  if [ -d $CDF/resources/crosscompiler/ ]; then
    rm -rf $CDF/resources/crosscompiler/
  fi
  if [ -d $CDF/out/ ]; then
    rm -rf $CDF/out/
  fi
  if [ -d $CDF/resources/logs/ ]; then
    rm -rf $CDF/resources/logs/
  fi
  echo -e "   Done"
sleep 1.5
fi

# Function to clear KB-E Environment
kbeclear () {
echo -e "$GREEN$BLD - Performing a Cleaning...$WHITE"
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

# Start
# KB-E Version
KBV=1.0
clear # Clear user UI
unset CWK
X=0
until [ $X = 21 ]; do
  X=$((X+1))
  unset VARIANT$X
done

# Tittle with style
echo -e "$WHITE"
echo -e "██╗  ██╗███████╗██████╗ ███╗   ██╗███████╗██╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ██╗███╗   ██╗ ██████╗"; sleep 0.05
echo -e "██║ ██╔╝██╔════╝██╔══██╗████╗  ██║██╔════╝██║     ██╔══██╗██║   ██║██║██║     ██╔══██╗██║████╗  ██║██╔════╝"; sleep 0.05
echo -e "█████╔╝ █████╗  ██████╔╝██╔██╗ ██║█████╗  ██║     ██████╔╝██║   ██║██║██║     ██║  ██║██║██╔██╗ ██║██║  ███╗"; sleep 0.05
echo -e "██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╗██║██╔══╝  ██║     ██╔══██╗██║   ██║██║██║     ██║  ██║██║██║╚██╗██║██║   ██║"; sleep 0.05
echo -e "██║  ██╗███████╗██║  ██║██║ ╚████║███████╗███████╗██████╔╝╚██████╔╝██║███████╗██████╔╝██║██║ ╚████║╚██████╔╝"; sleep 0.05
echo -e "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝ "; sleep 0.05
echo -e "                                                                                                        "; sleep 0.05
echo -e "              ███████╗███████╗███████╗███████╗███╗   ██╗████████╗██╗ █████╗ ██╗     ███████╗         "; sleep 0.05
echo -e "              ██╔════╝██╔════╝██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║██╔══██╗██║     ██╔════╝        "; sleep 0.05
echo -e "              █████╗  ███████╗███████╗█████╗  ██╔██╗ ██║   ██║   ██║███████║██║     ███████╗   $GREEN$BLD KB-E v$KBV$WHITE"; sleep 0.05
echo -e "              ██╔══╝  ╚════██║╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██╔══██║██║     ╚════██║    $GREEN$BLD By Artx$WHITE"; sleep 0.05
echo -e "              ███████╗███████║███████║███████╗██║ ╚████║   ██║   ██║██║  ██║███████╗███████║   "; sleep 0.05
echo -e "              ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝    "
echo " "
echo -e "$GREEN$BLD  - Initializing...$RATT"
echo " "
sleep 0.5

# Initialize KB-E Resources and Functions
. resources/other/folders.sh
. resources/paths.sh
. resources/programtools.sh
. resources/megaconfig.sh
#. resources/megadlt.sh
. resources/scripts/buildkernel.sh
. resources/scripts/makedtb.sh
. resources/scripts/makeanykernel.sh
#. scripts/makearoma.sh Disabled for now
. resources/scripts/upload.sh
. resources/runsettings.sh

if [ "$CWK" = "n" ] || [ "$CWK" = "N" ]; then
  return 1
fi
echo " "

# Clear some variables
unset bool; unset VV; unset VARIANT; unset DEFCONFIG; unset X; unset -f essentials

# Main command, you'll tell here to the program what to do
essentials () {
  # Get actual path
  CURR=$(pwd)
  # Instructions
  if [ "$1" = "" ]; then
    echo " "
    echo "Usage: essentials --kernel (Builds the kernel)                   | "
    echo "                  --dtb (Builds device tree image)               | These flags "
    echo "                  --anykernel (Builds the kernel installer)      | can be combined"
    echo "                  --upload (Upload the kernel installer to MEGA) | "
    echo "                                                                   "
    echo "                  --all (Does everything mentioned above)        | Work alone "
    echo " "
    echo "For more information use 'kbhelp' command"
    echo " "
  fi
  # If user defined --kernel flag, Build kernel
  if [ "$1" = "--kernel" ] || [ "$2" = "--kernel" ] || [ "$3" = "--kernel" ] || [ "$4" = "--kernel" ]; then
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      def=DEFCONFIG$(($i-1)); [[ ${!def} ]];
      DEFCONFIG=${!def}
      VARIANT=${!var}
      buildkernel
    done
  fi

  # If user defined --dtb flag, Build dtb (dt.img (Device Tree Image))
  if [ "$1" = "--dtb" ] || [ "$2" = "--dtb" ] || [ "$3" = "--dtb" ] || [ "$4" = "--dtb" ]; then
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      VARIANT=${!var}
      build_dtb
    done
  fi

  # If user defined --make_anykernel flag, Build AnyKernel Installer
  if [ "$1" = "--anykernel" ] || [ "$2" = "--anykernel" ] || [ "$3" = "--anykernel" ] || [ "$4" = "--anykernel" ]; then
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      def=DEFCONFIG$(($i-1)); [[ ${!def} ]];
      DEFCONFIG=${!def}
      VARIANT=${!var}
      make_anykernel
    done
  fi  

  # If user defined --upload flag, Upload the last built Installer
  if [ "$1" = "--upload" ] || [ "$2" = "--upload" ] || [ "$3" = "--upload" ] || [ "$4" = "--upload" ]; then
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      VARIANT=${!var}
      megaupload
    done
  fi

  # If user defined --all flag, do everything automatically
  if [ "$1" = "--all" ]; then
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      def=DEFCONFIG$(($i-1)); [[ ${!def} ]];
      DEFCONFIG=${!def}
      VARIANT=${!var}
      buildkernel
    done
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      VARIANT=${!var}
      build_dtb
    done
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      VARIANT=${!var}
      make_anykernel
    done
    i=1
    while var=VARIANT$((i++)); [[ ${!var} ]]; do
      VARIANT=${!var}
      megaupload
    done
  fi
  cd $CURR; unset CURR
}

# Done
if [ "$RD" = "1" ]; then
  echo -e "$GREEN$BLD - Kernel-Building Essentials it's ready!$RATT"
  echo " "
else
  echo -e "$RED$BLD - Session cancelled$RATT"
  echo " "
  unset -f essentials
fi

