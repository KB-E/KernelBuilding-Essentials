# Installer zips building solution (AnyKernel)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

make_anykernel () {
# Tittle
echo -e "$LCYAN$BLD   ## AnyKernel Installer Building Script (AnyKernel) ##$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e "   KERNEL: $KERNELNAME; VARIANT: $VARIANT; DATE: $DATE"

# Starting the real process!
echo " "
echo -e "$GREEN$BLD - Initializing Flasheable zip Build...$RATT$WHITE"
# -----------------------
cd $TF
# Kernel Update
if [ -f $ZIN/$VARIANT ]; then
  echo " "
  echo -e "$GREEN$BLD - Updating Kernel...$RATT$WHITE"
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

# Make the kernel installer zip
echo -ne "$RED$BLD - Building Flasheable zip for $VARIANT...$RATT$WHITE"
zip -r9 "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip * &> /dev/null
mv "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip $NZIPS/
echo -e "$LCYAN$BLD Done!$RATT"
echo " "
cd $CURF
}

# Done here
echo -e "$WHITE * Function 'make_anykernel' Loaded$RATT"
