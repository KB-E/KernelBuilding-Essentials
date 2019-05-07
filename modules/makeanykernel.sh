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
        rm -rf $AKFOLDER
        echo -e "$GREENBLD   Done$WHITE"
      elif [ "$CLRAKF" = "n" ] || [ "$CLRAKF" = "N" ]; then
        STOPD=1
      fi
    fi
    if [ "$STOPD" != "1" ]; then
      echo " "
      echo -ne "$GREEN$BLD - Downloading AnyKernel Source..."
      git clone https://github.com/osm0sis/AnyKernel2.git $AKFOLDER &> /dev/null
      echo -e "$WHITE Done"
    else
      echo -e "$RED$BLD - Download cancelled$WHITE"
    fi
  fi
done
unset AKBO; unset STOPD; unset CLRAKF;

function anykernel() {
# Check if we're building for 1 or more Variants
checkvariants
if [ "$MULTIVARIANT" = true ] && [ "$LOCKMA" != true ]; then
  i=1
  LOCKMA=true
  while var=VARIANT$((i++)); [[ ${!var} ]]; do
    def=DEFCONFIG$(($i-1)); [[ ${!def} ]];
    DEFCONFIG=${!def}
    VARIANT=${!var}
    anykernel --no-spam
  done
unset LOCKMA
return 1
fi
if [ "$MULTIVARIANT" = false ]; then
  DEFCONFIG=$DEFCONFIG1
  VARIANT=$VARIANT1
fi

# Cancel if theres no Kernel built
if [ -f $ZI$VARIANT.gz-dtb ] || [ -f $ZI$VARIANT.gz ] || [ -f $ZI$VARIANT ]; then
  sleep 0.1
else
  echo " "
  echo -e "$RED$BLD   There's no Kernel built for $VARIANT, aborting..."
  echo -e "$WHITE   Did you built the Kernel?"
  echo -e "$RATT"
  return 1
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
echo -e "$GREEN$BLD   --------------------------$WHITE"
echo -e "$WHITE - AnyKernel Installer Building Script  $RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e "   Kernel:$GREEN$BLD $KERNELNAME$WHITE; Variant:$GREEN$BLD $VARIANT$WHITE; Date:$GREEN$BLD $DATE$WHITE"
else
echo " "
echo -e "$GREEN$BLD   --------------------------$WHITE"
echo -ne " - Building AnyKernel for $VARIANT... "
fi

# Setup MakeAnykernel
checkfolders --silent
# Check MakeAnykerel folders
if [ "$1" != "--no-spam" ]; then echo -ne "$WHITE   Checking MakeAnykernel folders..."; fi
sleep 0.5
akfolder () {
  if [ ! -d $CDF/$FD ]; then
    mkdir $CDF/$FD
  fi
}
FD=out/AnyKernel; akfolder
unset FD
if [ "$1" != "--no-spam" ]; then echo -ne "$GREEN$BLD Done$RATT"; fi

# Paths
NZIPS=$CDF/"out/AnyKernel" # New Zips built output folder

# Check Zip Tool
checkziptool
# Check buildkernel.sh KBUILDFAILED variable
if [ "$KBUILDFAILED" = "1" ]; then
  echo -e "$RED$BLD   Warning:$WHITE the previous kernel were not built successfully"
  read -p "Ignore this warning and continue? [Y/N]: " CAB           # KBUILDFAILED tell us if the lastest kernel
  if [ "$CAB" = "y" ] || [ "$CAB" = "Y" ]; then                     # building failed, but, we still have the 
    echo -e "$WHITE   Using last built Kernel for $VARIANT..."      # last successfully built kernel so this will
  else                                                              # ask the user if he wants to continue building
    echo -e "$WHITE   Aborting..."                                  # the anykernel installer, if not, exit the 
    echo -e "$GREEN$BLD   --------------------------$WHITE"         # module.
    cd $CDF
    return 1
  fi
fi
# Starting the real process!
# -----------------------
# Kernel Update
while true
do
  if [ "$ARCH" = "arm" ]; then
    cp $ZI/$VARIANT $AKFOLDER/zImage
    break
  elif [ "$ARCH" = "arm64" ] && [ -f $ZI$VARIANT.gz-dtb ]; then 
    cp $ZI/$VARIANT.gz-dtb $AKFOLDER/Image.gz-dtb
    break
  elif [ "$ARCH" = "arm64" ] && [ -f $ZI$VARIANT.gz ]; then
    cp $ZI/$VARIANT.gz $AKFOLDER/Image.gz
    break
  elif [ "$ARCH" = "arm64" ] && [ -f $ZI$VARIANT ]; then
    cp $ZI/$VARIANT $AKFOLDER/Image
    break
  fi
done
if [ "$1" != "--no-spam" ]; then
  echo -e "$WHITE$BLD   Kernel Updated"
fi
if [ "$MAKEDTB" = "1" ]; then 
  if [ -f $DT/$VARIANT ]; then
    cp $DT/$VARIANT $AKFOLDER/dtb
    if [ "$1" != "--no-spam" ]; then 
      echo -e "$WHITE$BLD   DTB Updated"
      echo -e "   Done"
    fi
  else
    echo -e "$RED$BLD   DTB not found for $VARIANT, skipping..."
  fi
fi
# -----------------------

# Make the kernel installer zip
if [ "$1" != "--no-spam" ]; then
  echo -ne "$WHITE$BLD   Building Flasheable zip for $VARIANT...$RATT$WHITE"
else
  echo -ne "$WHITE   Building Installer..."
fi
cd $AKFOLDER
zip -r9 "$KERNELNAME"-v"$VERSION"-"$TARGETANDROID"_"$VARIANT".zip * &> /dev/null
mv "$KERNELNAME"-v"$VERSION"-"$TARGETANDROID"_"$VARIANT".zip $NZIPS/
echo -e "$GREEN$BLD Done!$RATT"
echo -e "$GREEN$BLD   --------------------------$WHITE"
# Clean anykernelfiles Folder
rm $AKFOLDER/zImage &> /dev/null
rm $AKFOLDER/Image.gz-dtb &> /dev/null
rm $AKFOLDER/Image.gz &> /dev/null
rm $AKFOLDER/Image &> /dev/null
rm $AKFOLDER/dtb &> /dev/null
cd $CDF
}
export -f anykernel; log -f anykernel $KBELOG
