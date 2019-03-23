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
# Load ProgramTools
. $CDF/resources/programtools.sh
# Load title 
. $CDF/resources/other/programtitle.sh

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
if [ -f $CDF/resources/other/modulelist.txt ]; then
  rm $CDF/resources/other/modulelist.txt
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

# DisplayTitle
title

# Initialize KB-E Resources and Modules
loadresources
checktools

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
    i=1
    echo " "
    echo "Usage: essentials --kernel (Builds the kernel)"
    echo "                  --dtb (Builds device tree image)"
    i=1
    while var=MODULE$((i++)); [[ ${!var} ]]; do
    path=MPATH$(($i-1)); [[ ${!path} ]];
      echo "                  --${!var} ($(grep MODULE_DESCRIPTION ${!path} | cut -d '=' -f2))"
    done
    echo " "
    echo "                  --all (Does everything mentioned above)        | Work alone "
    echo " "
    echo "For more information use 'kbhelp' command"
    echo " "
  fi

  # First of all, the program buildkernel and makedtb
  for g in $@; do
    if [ "$g" = "--kernel" ]; then
      checkvariants
      if [ "$MULTIVARIANT" = "true" ]; then
        while var=VARIANT$((i++)); [[ ${!var} ]]; do
          def=DEFCONFIG$(($i-1)); [[ ${!def} ]];
          DEFCONFIG=${!def}
          VARIANT=${!var}
          buildkernel
        done
      else
        VARIANT=$VARIANT1
        DEFCONFIG=$DEFCONFIG1
        buildkernel
      fi
    fi
  done

  for s in $@; do
    if [ "$s" = "--dtb" ]; then
      checkvariants
      if [ "$MULTIVARIANT" = "true" ]; then
        while var=VARIANT$((i++)); [[ ${!var} ]]; do
          VARIANT=${!var}
          makedtb
        done
      else
        VARIANT=$VARIANT1
        makedtb
      fi
    fi
  done

  # Get and execute the modules
  for a in $@; do
    i=1
    while var=MODULE$((i++)); [[ ${!var} ]]; do
      path=MPATH$(($i-1)); [[ ${!path} ]];
      if [ "--$(grep MODULE_FUNCTION_NAME ${!path} | cut -d '=' -f2)" = "$a" ]; then
        EXEC=$(grep MODULE_FUNCTION_NAME ${!path} | cut -d '=' -f2)
        $EXEC
      fi
    done
  done
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

