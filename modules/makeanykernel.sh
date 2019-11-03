#!/bin/bash
# AnyKernel Installer Zips building solution (AnyKernel)
# By Artx <artx4dev@gmail.com>

# ---------------------------
# Identify the Module:
# ---------------------------
# MODULE_NAME=MakeAnykernel
# MODULE_VERSION=1.0
# MODULE_DESCRIPTION="AnyKernel Installer building Module for KB-E by Artx"
# MODULE_PRIORITY=5
# MODULE_FUNCTION_NAME=anykernel
# ---------------------------

# Path variable
AKFOLDER=$device_kernel_path/anykernelfiles
AKOUT=$device_kernel_path/out/anykernel

# If the anykernelfiles folder is missing for the current
# kernel, prompt for its configuration
if [ ! -d $AKFOLDER ]; then
  # AnyKernel Required Data by User
  echo " "
  echo -e "$THEME$BLD - Choose an option for AnyKernel Installer: "
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
      echo -ne "$THEME$BLD - Downloading AnyKernel Source..."
      git clone https://github.com/osm0sis/AnyKernel2.git $AKFOLDER &> /dev/null
      echo -e "$WHITE Done"
    fi
    if [ "$AKBO" = "2" ]; then
      mkdir $AKFOLDER
    fi
  done
  unset AKBO
fi

# Enable/Disable Kernel Update
if [ ! -f $device_kernel_path/akconfig ]; then
  echo " "
  touch $device_kernel_path/akconfig
  echo -ne "$WHITE   Automatically update the Kernel image while building the AnyKernel? [Y/N]: "
  read anykernel_kupdate
  if [ "$anykernel_kupdate" = "Y" ] || [ "$anykernel_kupdate" = "y" ]; then
    echo "export enable_kupdate=y" >> $device_kernel_path/akconfig
  fi
  echo -e "$RATT"
fi

function anykernel() {
# Read version
readfromdevice version
# Load AK Config file
source $device_kernel_path/akconfig
# Tittle
echo -ne "$THEME$BLD"
echo -e "     _            _  __                 _ "
echo -e "    /_\  _ _ _  _| |/ /___ _ _ _ _  ___| | "
echo -e "   / _ \| ' \ || | ' </ -_) '_| ' \/ -_) | "
echo -e "  /_/ \_\_||_\_, |_|\_\___|_| |_||_\___|_| "
echo -e "             |__/                         "
echo " "
echo -e "$THEME$BLD   --------------------------$WHITE"
echo -e "$WHITE - AnyKernel Installer Building Script  $RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e "   Kernel:$THEME$BLD $kernel_name$WHITE; Variant:$THEME$BLD $device_variant$WHITE; Date:$THEME$BLD $DATE$WHITE"

# Check MakeAnykerel out folder
if [ ! -d $AKOUT ]; then
  mkdir $AKOUT
fi

# Check Zip Tool
checkziptool &> /dev/null
# Check buildkernel.sh KBUILDFAILED variable
if [ "$kernel_build_failed" = "true" ]; then
  echo -e "$RED$BLD   Warning:$WHITE the previous kernel were not built successfully"
  read -p "Ignore this warning and continue? [Y/N]: " CAB           # KBUILDFAILED tell us if the lastest kernel
  if [ "$CAB" = "y" ] || [ "$CAB" = "Y" ]; then                     # building failed, but, we still have the
    echo -e "$WHITE   Using last built Kernel for $VARIANT..."      # last successfully built kernel so this will
  else                                                              # ask the user if he wants to continue building
    echo -e "$WHITE   Aborting..."                                  # the anykernel installer, if not, exit the
    echo -e "$THEME$BLD   --------------------------$WHITE"         # module.
    cd $kbe_path
    return 1
  fi
fi
# Update Kernel image and DTB when its enabled
if [ "$enable_kupdate" = "y" ]; then
  # Starting the real process!
  # -----------------------
  # Kernel Update
  selectimage
  if [ "$selected_image" = "none" ] || [ -z "$selected_image" ]; then
    echo -e "$RED$BLD Error:$WHITE Kernel is not built, aborting..."
    return 1
  else
    cp $KOUT/$selected_image $AKFOLDER/
  fi
  echo -e "$WHITE$BLD   Kernel Updated. $selected_image Automatically selected"
  if [ -f $DTOUT/$device_variant ]; then
    cp $DTOUT/$device_variant $AKFOLDER/dtb
    echo -e "$WHITE$BLD   DTB Updated"
    echo -e "   Done"
  fi
  # -----------------------
else
  echo -e "$WHITE   Automatic Kernel update disabled"
fi

# Make the kernel installer zip
export ZIPNAME="$kernel_name"-v"$kernel_version"-"$kernel_arch"-"$release_type"-"$target_android"_"$device_variant".zip
KREVF=$device_kernel_path/$kernel_name.rev
if [ $release_type = "Beta" ]; then
  if [ ! -f $KREVF ]; then
    touch $KREVF
    echo 0 > $KREVF
  fi
  REVN=$(cat $KREVF)
  REVSUM=$((1+REVN))
  export REV=$REVSUM
  echo $REV > $KREVF
  export ZIPNAME="$kernel_name"-v"$kernel_version"-"$kernel_arch"-"$release_type"-Rev"$REV"-"$target_android"_"$device_variant".zip
fi
echo -e "$THEME$BLD   Zip Name: $WHITE$ZIPNAME"
echo -ne "$WHITE$BLD   Building Flasheable zip for $device_variant...$RATT$WHITE"
cd $AKFOLDER
zip -r9 $ZIPNAME * &> /dev/null
mv $ZIPNAME $AKOUT/
echo -e "$THEME$BLD Done!$RATT"
echo -e "$THEME$BLD   --------------------------$WHITE"
}
export -f anykernel; kbelog -f anykernel
