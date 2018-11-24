#!/bin/bash

# AnyKernel Installer Zips building solution (AnyKernel)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Identify the Module
MODULE_NAME=MakeAnykernel
MODULE_VERSION=1.0
MODULE_DESCRIPTION="AnyKernel Installer building Module for KB-E by Artx"
MODULE_PRIORITY=5 # Priority level is from 1 to 10

# AnyKernel Source Select
BTYPE=AnyKernel
echo " "
echo -e "$GREEN$BLD - Choose an option for $BTYPE Installer: "
echo " "
echo -e "$WHITE   1) Use local $GREEN$BLD$BTYPE$WHITE Template"
echo -e "   2) Select a template from your 'templates' folder"
echo -e "   3) Let me manually set my template"
echo " "
until [ "$AKBO" = "1" ] || [ "$AKBO" = "3" ]; do
  read -p "   Your option [1/2/3]: " AKBO
  if [ "$AKBO" != "1" ] && [ "$AKBO" != "2" ] && [ "$AKBO" != "3" ]; then
    echo " "
    echo -e "$RED$BLD - Error, invalid option, try again..."
    echo -e "$WHITE"
  fi
  if [ "$AKBO" = "2" ]; then
    if [ ! -f $UTF/*/anykernel.sh ]; then
      echo " "
      echo -e "$RED$BLD There isn't any template inside 'templates' folder, choose other option$RATT"
      echo " "
    else
      CURR=$(pwd)
      cd $UTF
      select d in */; do test -n "$d" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
      cd $CURR; unset CURR
      export TF=$UTF/$d
      break
    fi
  fi
done

if [ "$AKBO" = "1" ]; then
  # Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
  export TF=$AKT
  # If this file is missing we can assume that we need to restore this template
  if [ ! -f $AKT/anykernel.sh ]; then
  checkfolders
  templatesconfig
  fi
fi

if [ "$AKBO" = "3" ]; then
  # Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
  export TF=$AKT
fi

make_anykernel () {
# Tittle
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

# Setup MakeAnykernel
checkfolders
checkakfolders () {
  # Check MakeAnykerel folders
  echo " "
  echo -e "$GREEN$BLD - Checking MakeAnykernel folders..."
  sleep 0.5
  akfolder () {
    if [ ! -d $CDF/$FD ]; then
      mkdir $CDF/$FD
      echo -e "$WHITE   Generated $FD folder$RATT"
    fi
  }
  FD=out/AnyKernel; folder
  unset FD
  echo -e "$GREEN$BLD   Done$RATT"
}

# Paths
NZIPS=$CDF/"out/AnyKernel/" # New Zips built output folder

# Check Zip Tool
checkziptool
# Starting the real process!
# -----------------------
cd $TF
# Kernel Update
if [ -f $ZIN/$VARIANT ]; then
  echo " "
  echo -e "$GREEN$BLD   Replacing files...$RATT$WHITE"
  echo " "
  if [ $ARCH = arm ]; then
    cp $ZIN/$VARIANT $TF/zImage
  elif [ $ARCH = arm64 ]; then 
    cp $ZIN/$VARIANT $TF/Image.gz-dtb
  fi
  echo -e "$WHITE$BLD   Kernel Updated"
  if [ $ARCH = arm ]; then
    if [ $MAKEDTB = 1 ]; then cp $DT/$VARIANT $TF/dtb; echo -e "$WHITE$BLD   DTB Updated"; fi
  fi
  echo -e "   Done"
fi
echo " "
# -----------------------

# Make the kernel installer zip
echo -ne "$WHITE$BLD   Building Flasheable zip for $VARIANT...$RATT$WHITE"
zip -r9 "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip * &> /dev/null
mv "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip $NZIPS/
echo -e "$GREEN$BLD Done!$RATT"
echo " "
cd $CURF
}
