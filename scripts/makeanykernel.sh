# Installer zips building solution (AnyKernel)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

make_anykernel () {
  if [ "$STOP" = 1 ]; then
    export STOP=0
    echo -e "$RED$BLD - Stopping AnyKernel Installer Creation..."
    return 1
  fi
# Tittle
echo -e "$GREEN$BLD - AnyKernel Installer Building Script (AnyKernel)$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e " DATE: $DATE"

# Get the folder that we're going to use to build our AnyKernel Installer
AKCDF=$TF

# Start
echo " "
echo -e "$GREEN$BLD - Checking out folder...$RAT$WHITE"

if [ ! -d $CDF/out ]; then
echo " "
echo -e "$RED   Error, theres no 'out' folder! Please run 'checkenviroment' command and try again.$RATT"
export STOP=1
return 1
fi

# If you're here, theres nothing blocking the AnyKernel Zip Building, congrats ;)
echo -e "$WHITE   Checking done"
echo " "
# -------------------------------------------------------------------------------

# Starting the real process!
echo -e "$GREEN$BLD Initializing Flasheable zip Build...$RATT$WHITE"
echo " "

# -----------------------
echo -e "$GREEN$BLD Updating Flasheable Zip contents for $VARIANT...$RATT$WHITE"
echo " "
echo "  - Temp folder cleared"
echo " "

# Kernel Update
if [ -f $ZI/$VARIANT ]; then
  echo " "
  echo -e "$GREEN$BLD Updating Kernel...$RATT$WHITE"
  cd $AKCDF
  echo " "
  cp $ZI/$VARIANT $AKCDF/zImage
  echo -e "$WHITE$BLD - Kernel Updated"
  if [ $MAKEDTB = 1 ]; then cp $DT/$VARIANT $AKCDF/dtb; echo -e "$WHITE$BLD - DTB Updated"; fi
  echo -e " Done"
fi
echo " "

# Make the kernel installer zip
echo -e "$LBLUE$BLD - Building Flasheable zip for $VARIANT...$RATT$WHITE"
zip -r9 $KERNELNAME-v"$VERSION"-$TARGETANDROID-AnyKernel_"$DATE"_"$VARIANT".zip * &> /dev/null
mv $KERNELNAME-v"$VERSION"-$TARGETANDROID-AnyKernel_"$DATE"_"$VARIANT".zip $NZIPS/
cd $CDF
echo -e "$LCYAN$BLD ## Flasheable zip for $VARIANT Ready! ##$RATT"
echo " "
}

# Done here
echo -e "$WHITE * Function 'make_anykernel' Loaded$RATT"
