# Builds upload solution (MegaTools required)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

megaupload () {
# Start
if [ "$NOUP" = 1 ]; then
  export NOUP=0
  echo -e "$RED - Upload is disabled, Run 'megacheck' Command to Re-Configure MEGA"
  return 1
fi
echo -e "$GREEN$BLD - Initializing Kernel(s) upload...$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e "   KERNEL: $KERNELNAME; VARIANT: $VARIANT; DATE: $DATE"
megacheck
echo " "
  # Optional
  if [ "$BLDTYPE" = "A" ]; then
    megarm /Root/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AROMA_"$DATE"_"$VARIANT"_KB-E"$KBV".zip &> /dev/null
    megals --reload &> /dev/null
  elif [ "$BLDTYPE" = "K" ]; then
    megarm /Root/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip &> /dev/null
    megals --reload &> /dev/null
  fi
  # --------
  # Upload the Kernel Installer(s)
  US=0
  echo -e "$GREEN$BLD - Uploading Zip for $VARIANT to MEGA...$WHITE"
  if [ "$BLDTYPE" = "A" ]; then
    megaput $NZIPS/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AROMA_"$DATE"_"$VARIANT"_KB-E"$KBV".zip
    echo -e "   Done$RATT"
    US=1
  elif [ "$BLDTYPE" = "K" ]; then
    megaput $NZIPS/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip
    echo -e "   Done$RATT"
    US=1
  fi
  if [ $US = 0 ]; then
    echo -e "$RED$BLD - No file to upload!$RATT"
    unset US
  fi
  echo -e "$RATT"
}

echo -e "$WHITE * Function 'megaupload' Loaded$RATT"
