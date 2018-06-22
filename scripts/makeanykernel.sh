# Installer zips building solution (AnyKernel)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

make_anykernel () {
# Tittle
echo -e "$LCYAN$BLD   ## AnyKernel Installer Building Script (AnyKernel) ##$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e "   KERNEL: $KERNELNAME; VARIANT: $VARIANT; DATE: $DATE"
unset DATE

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
  cp $ZIN/$VARIANT $TF/zImage
  echo -e "$WHITE$BLD   Kernel Updated"
  if [ $MAKEDTB = 1 ]; then cp $DT/$VARIANT $TF/dtb; echo -e "$WHITE$BLD   DTB Updated"; fi
  echo -e "   Done"
fi
echo " "

# Make the kernel installer zip
echo -e "$LBLUE$BLD - Building Flasheable zip for $VARIANT...$RATT$WHITE"
zip -r9 "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip * &> /dev/null
mv "$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip $NZIPS/
cd $CDF
echo -e "$LCYAN$BLD   ## AnyKernel Installer for $VARIANT Ready! ##$RATT"
echo " "
}

# Done here
echo -e "$WHITE * Function 'make_anykernel' Loaded$RATT"
