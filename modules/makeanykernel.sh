#!/bin/bash

# AnyKernel Installer Zips building solution (AnyKernel)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# ---------------------------
# Identify the Module:
# ---------------------------
# MODULE_NAME=MakeAnykernel
# MODULE_VERSION=1.0
# MODULE_DESCRIPTION="AnyKernel Installer building Module for KB-E by Artx"
# MODULE_PRIORITY=5
# MODULE_FUNCTION_NAME=anykernel
# ---------------------------

# Variables and config
AKFOLDER=$CDF/anykernelfiles
AKSH=$AKFOLDER/anykernel.sh
if [ ! -d $AKFOLDER ]; then
  mkdir $AKFOLDER
fi

# AnyKernel Required Data by User
echo " "
echo -e "$GREEN$BLD - Choose an option for AnyKernel Installer: "
echo " "
echo -e "$WHITE   1) Download the AnyKernel Source and use it"
echo -e "   2) Manually set the AnyKernel files"
echo " "
until [ "$AKBO" = "1" ] || [ "$AKBO" = "2" ]; do
  read -p "   Your option [1/2]: " AKBO
  if [ "$AKBO" != "1" ] && [ "$AKBO" != "2" ]; then
    echo " "
    echo -e "$RED$BLD - Error, invalid option, try again..."
    echo -e "$WHITE"
  fi
  if [ "$AKBO" = "1" ]; then
    echo " "
    if [ -f $AKSH ]; then
      read -p "   AnyKernel Files Folder is not Empty, clean it? [Y/N]: " CLRAKF
      if [ "$CLRAKF" = "y" ] || [ "$CLRAKF" = "Y" ]; then
        rm -rf $AKFOLDER/*
        echo -e "$GREENBLD   Done$WHITE"
      elif [ "$CLRAKF" = "n" ] || [ "$CLRAKF" = "N" ]; then
        STOPD=1
      fi
      unset CLRAKF
    fi
    if [ "$STOPD" != "1" ]; then
      echo " "
      echo -ne "$GREEN$BLD - Downloading AnyKernel Source..."
      git clone https://github.com/osm0sis/AnyKernel2.git $AKFOLDER &> /dev/null
      echo -e "$WHITE Done"
    else
      echo -e "$RED$BLD - Download cancelled$WHITE"
    fi
    unset STOPD
  fi
done
unset  AKBO

anykernel () {
# Check if we're building for 1 or more Variants
checkvariants
if [ "$MULTIVARIANT" = true ] && [ "$LOCKMA" != true ]; then
  i=1
  LOCKMA=true
  while var=VARIANT$((i++)); [[ ${!var} ]]; do
    def=DEFCONFIG$(($i-1)); [[ ${!def} ]];
    DEFCONFIG=${!def}
    VARIANT=${!var}
    make_anykernel --no-spam
  done
fi
if [ "$MULTIVARIANT" = false ]; then
  DEFCONFIG=$DEFCONFIG1
  VARIANT=$VARIANT1
fi

# Tittle
if [ "$1" != "--no-spam" ]; then
echo -ne "$GREEN$BLD"
echo -e "     _            _  __                 _ "
echo -e "    /_\  _ _ _  _| |/ /___ _ _ _ _  ___| | "
echo -e "   / _ \| ' \ || | ' </ -_) '_| ' \/ -_) | "
echo -e "  /_/ \_\_||_\_, |_|\_\___|_| |_||_\___|_| "
echo -e "             |__/                         "
echo " "
echo -e "$GREEN$BLD - AnyKernel Installer Building Script  $RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e "   Kernel: $KERNELNAME; Variant: $VARIANT; Date: $DATE"
else 
echo -ne "$GREEN$BLD - Building AnyKernel for $VARIANT... "
fi

# Setup MakeAnykernel
checkfolders
# Check MakeAnykerel folders
if [ "$1" != "--no-spam" ]; then echo -ne "$GREEN$BLD - Checking MakeAnykernel folders..."; fi
sleep 0.5
akfolder () {
  if [ ! -d $CDF/$FD ]; then
    mkdir $CDF/$FD
  fi
}
FD=out/AnyKernel; akfolder
unset FD
if [ "$1" != "--no-spam" ]; then echo -e "$WHITE Done$RATT"; fi

# Paths
NZIPS=$CDF/"out/AnyKernel" # New Zips built output folder

# Check Zip Tool
checkziptool
# Starting the real process!
# -----------------------
# Kernel Update
if [ -f $ZIN/$VARIANT ]; then
  if [ "$1" != "--no-spam" ]; then
    echo " "
    echo -e "$GREEN$BLD   Replacing files...$RATT$WHITE"
    echo " "
  else
    echo -ne "$GREEN$BLD - Updating Files..."
  fi
  if [ $ARCH = arm ]; then
    cp $ZIN/$VARIANT $AKFOLDER/zImage
  elif [ $ARCH = arm64 ]; then 
    cp $ZIN/$VARIANT $AKFOLDER/Image.gz-dtb
  fi
  if [ "$1" != "--no-spam" ]; then
    echo -e "$WHITE$BLD   Kernel Updated"
  fi
  if [ $MAKEDTB = 1 ]; then 
    cp $DT/$VARIANT $AKFOLDER/dtb
    if [ "$1" != "--no-spam" ]; then 
      echo -e "$WHITE$BLD   DTB Updated"
      echo -e "   Done"
    fi
  fi
fi
echo " "
# -----------------------

# Make the kernel installer zip
if [ "$1" != "--no-spam" ]; then
  echo -ne "$WHITE$BLD   Building Flasheable zip for $VARIANT...$RATT$WHITE"
else
  echo -ne "$GREEN$BLD Building Installer..."
fi
cd $AKFOLDER
zip -r9 "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip * &> /dev/null
mv "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip $NZIPS/
echo -e "$GREEN$BLD Done!$RATT"
echo " "
cd $CDF
}


