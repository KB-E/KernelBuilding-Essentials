# Builds upload solution (MegaTools required)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

megaupload () {
# Start
if [ "$STOP" = 1 ]; then
  export STOP=0
  echo -e "$RED$BLD - Stopping upload..."
  return 1
fi
if [ "$NOUP" = 1 ]; then
  export NOUP=0
  echo -e "$RED - Upload is disabled, Run 'megacheck' Command to Re-Configure MEGA"
  return 1
fi
echo -e "$BOLD$GREEN Initializing Kernel(s) upload...$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e " DATE: $DATE"
echo " "
  # Optional
  if [ $BLDTYPE = A ]; then
    megarm $MEGAPATH1/$VARIANT/$KERNELNAME-v"$VERSION"U-AROMA_"$DATE"_"$VARIANT".zip &> /dev/null
  elif [ $BLDTYPE = K ]; then
    megarm $MEGAPATH2/$VARIANT/$KERNELNAME-v"$VERSION"U-AnyKernel_"$DATE"_"$VARIANT".zip &> /dev/null
  fi
  # --------
  # Upload the Kernel Installer(s)
  echo " Uploading Zip for $VARIANT to MEGA..."
  if [ $BLDTYPE = A ]; then
    megaput --path $MEGAPATH1 $NZIPS/$KERNELNAME-v"$VERSION"-$TARGETANDROID-AROMA_"$DATE"_"$VARIANT".zip
  elif [ $BLDTYPE = K ]; then
    megaput --path $MEGAPATH2 $NZIPS/$KERNELNAME-v"$VERSION"-$TARGETANDROID-AnyKernel_"$DATE"_"$VARIANT".zip
  fi
  echo -e " Done$RATT"
  echo " "
}

echo -e "$WHITE * Function 'megaupload' Loaded$RATT"
