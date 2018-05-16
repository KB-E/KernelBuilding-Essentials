# Installer zips building solution (AnyKernel)
# By Artx/Stayn <jesusgabriel.91@gmail.com>

make_anykernel () {
  if [ "$STOP" = 1 ]; then
    export STOP=0
    echo -e "$RED$BLD - Stopping AnyKernel Installer Creation..."
    return 1
  fi
# Tittle
echo -e "$GREEN$BLD - Installer Zips Building Script (AnyKernel)$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e " DATE: $DATE"

# Start
echo " "
echo -e "$GREEN$BLD - Checking files and config...$RAT$WHITE"

if [ ! -d $CDF/out ]; then
echo " "
echo -e "$RED   Error, theres no 'out' folder! Please run 'checkenviroment' command and try again.$RATT"
return 1
fi

if [ ! -f $RAMDISKF/* ]; then
  echo " "
  echo -e "$WHITE - No ramdisk files to be added, skipping...$RATT"
fi

if [ $DLZIPS = 1 ]; then
ZIPERROR=0
if [ ! -f $ZIPS2/"$VARIANT".zip ]; then
  echo -e "$LRED$BLD   Zip for $VARIANT not found, downloading..."
  # The Base zip, this will be updated with the files speficied bellow
  # Set your MEGA path to download (The zip name MUST be equal to variant name)
  # Or manually copy the zip to the output folder
  megaget $MEGAAK/$VARIANT.zip --path $ZIPS2
  if [ ! -f $ZIPS2/"$VARIANT".zip ]; then # If Base Zip downloading failed, then
                                          # cancel anykernel build
    echo -e "$RED   Error downloading $VARIANT Base Zip, check the path$RATT"
    export ZIPERROR=1
    echo " "
  fi
fi
fi

# If you're here, theres nothing blocking the AnyKernel Zip Building, congrats ;)
echo -e "$WHITE   Checking done"
echo " "
# -------------------------------------------------------------------------------

# Starting the real process!
echo -e "$GREEN$BLD Initializing Flasheable zip Build...$RATT$WHITE"
echo " "

# Clear extracting folder
rm -rf $TMP2/*
# -----------------------
echo -e "$GREEN$BLD Updating Flasheable Zip contents for $VARIANT...$RATT$WHITE"
echo " "
echo "  - Temp folder cleared"
echo "  - Extracting $VARIANT files into temp..."; unzip $ZIPS2/"$VARIANT".zip -d $TMP2 &> /dev/null
echo "  - Extracting files sucessfully"
echo " "

# AnyKernel Files Update
if [ -f $ZI/$VARIANT ]; then
  echo " "
  echo -e "$GREEN$BLD Updating AnyKernel contents...$RATT$WHITE"
  cd $TMP2
  echo " "
  cp $ZI/$VARIANT $TMP2/zImage
  echo -e "$WHITE$BLD - Kernel Updated"
  if [ $MAKEDTB = 1 ]; then cp $DT/$VARIANT $TMP2/dtb; echo -e "$WHITE$BLD - DTB Updated"; fi
  # Update binary
  if [ -f $FILES2/update-binary ]; then
    cp $FILES2/update-binary $TMP2/META-INF/com/google/android/
    echo -e "$WHITE$BLD - update-binary Updated"
  fi
  # Update start-up script
  if [ -f $FILES2/ak-post_boot.sh ]; then
    cp $FILES2/ak-post_boot.sh $TMP2/ramdisk/sbin/
    echo -e "$WHITE$BLD - ak-post_boot.sh Updated"
  fi
  # Update anykernel methods
  if [ -f $FILES2/ak2-core.sh ]; then
    cp $FILES2/ak2-core.sh $TMP2/tools/
    echo -e "$WHITE$BLD - ak2-core.sh Updated"
  fi
  # Update anykernel script
  if [ -f $FILES2/anykernel.sh ]; then
    cp $FILES2/anykernel.sh $TMP2/
    echo -e "$WHITE$BLD - anykernel.sh Updated"
  fi
  # --------------------------
  # Another files update methods can be added here

  # ---------------------------------------------
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
