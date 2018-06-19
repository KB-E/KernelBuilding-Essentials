# Installer zips building solution (AROMA)
# By Artx/Stayn <jesusgabriel.91@gmail.com>


make_aroma () {
# Tittle
echo -e "$GREEN$BLD Installer Zips Building Script (AROMA)$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e " DATE: $DATE"

# Start
echo " "
echo -e "$GREEN$BLD Checking files...$RAT$WHITE"

if [ ! -d $CDF/out ]; then
echo " "
echo -e "$RED Error, theres no 'out' folder! Please run checkenviroment.sh and try again."
return 1
fi

zipd () {
  if [ ! -f $ZIPS/"$VARIANT".zip ]; then
    echo -e "$LRED$BLD Zip for $VARIANT not found, downloading..."
    # The Base zip, this will be updated with the files speficied bellow
    # Set your MEGA path to download (The zip name MUST be equal to variant name)
    # Or manually copy the zip to the output folder
    megaget $MEGAAROMA/"$VARIANT".zip --path $ZIPS &> /dev/null
    echo " Done"
    echo " "
  fi
}

VARIANT=d850; if [ $MAKED850 = 1 ]; then zipd; fi
VARIANT=d851; if [ $MAKED851 = 1 ]; then zipd; fi
VARIANT=d852; if [ $MAKED852 = 1 ]; then zipd; fi
VARIANT=d855; if [ $MAKED855 = 1 ]; then zipd; fi
VARIANT=ls990; if [ $MAKELS990 = 1 ]; then zipd; fi
VARIANT=vs985; if [ $MAKEVS985 = 1 ]; then zipd; fi
VARIANT=f400; if [ $MAKEF400 = 1 ]; then zipd; fi
VARIANT=dualsim; if [ $MAKEDUALSIM = 1 ]; then zipd; fi
echo -e " Done"
echo " "

echo -e "$GREEN$BLD Initializing Flasheable zip Build...$RATT$WHITE"
echo " "

makezip () {
  # Clear extracting folder
  rm -rf $TMP/*
  # -----------------------
  echo -e "$GREEN$BLD Updating Flasheable Zip contents for $VARIANT...$RATT$WHITE"
  echo " "
  echo "  - Temp folder cleared"
  echo "  - Extracting $VARIANT files into temp..."; unzip $ZIPS/"$VARIANT".zip -d $TMP &> /dev/null
  echo "  - Extracting files sucessfully"
  echo " "
  # Update AROMA Start Logo
  if [ -f $FILES/artx.png ]; then
    cp $FILES/artx.png $TMP/META-INF/com/google/android/aroma/
    echo "  - artx.png Updated"
  fi
  # Update Changelog
  if [ -f $FILES/changelog.txt ]; then
    cp $FILES/changelog.txt $TMP/META-INF/com/google/android/aroma/
    echo "  - changelog.txt Updated"
  fi
  # Update updater-script (AROMA)
  if [ -f $FILES/updater-script ]; then
    cp $FILES/updater-script $TMP/META-INF/com/google/android/
    echo "  - updater-script Updated"
  fi
  # Update aroma-script
  if [ -f $FILES/aroma-config ]; then
    cp $FILES/aroma-config $TMP/META-INF/com/google/android/
    echo "  - aroma-config Updated"
  fi
  # Update Spectrum Installer (Custom)
  if [ -f $FILES/spectrum2.zip ]; then
    cp $FILES/spectrum2.zip $TMP/spectrumzip/
    echo "  - spectrum2.zip Updated"
  fi
  # Update AROMA Theme
  if [ -d $FILES/g3 ]; then
    rm -rf $TMP/META-INF/com/google/android/aroma/themes/g3
    cp -rf $FILES/g3 $TMP/META-INF/com/google/android/aroma/themes/
    echo "  - Theme Updated"
  fi
  #Update Kernel Adiutor
  if [ -d $FILES/kerneladiutor.apk ]; then
    rm -rf $TMP/system/apps/ka/com.kerneladiutor.mod-1/base.apk
    cp $FILES/kerneladiutor.apk $TMP/system/apps/com.kerneladiutor.mod-1/base.apk
    echo "  - Kernel Adiutor updated"
  fi
  # AnyKernel Files Update
  if [ -f $ZI/$VARIANT ]; then
    echo " "
    echo -e "$GREEN$BLD Updating Kernel...$RATT$WHITE"
    rm -rf $TMP2/*
    unzip $TMP/anykernelzip/anykernel2.zip -d $TMP2 &> /dev/null
    cd $TMP2
    cp $ZI/$VARIANT $TMP2/zImage
    if [ $MAKEDTB = 1 ]; then cp $DT/$VARIANT $TMP2/dtb; fi
    cp $FILES/ak-post_boot.sh $TMP2/ramdisk/sbin/
    cp $FILES/ak2-core.sh $TMP2/tools/
    cp $FILES/anykernel.sh $TMP2/
    zip -r9 anykernel2.zip * &> /dev/null
    rm $TMP/anykernelzip/anykernel2.zip
    mv anykernel2.zip $TMP/anykernelzip/
    cd $CDF
    # Clear AnyKernel TMP Folder
    rm -rf $TMP2/*
    # --------------------------
    echo "  - Kernel Updated"
    # Another files update methods can be added here

    # ---------------------------------------------
  fi
  echo " "
  # Make the kernel installer zip
  echo -e "$LBLUE$BLD Building Flasheable zip for $VARIANT...$RATT$WHITE"
  cd $TMP
  zip -r9 $KERNELNAME-v"$VERSION"U-AROMA_"$DATE"_"$VARIANT".zip * &> /dev/null
  mv $KERNELNAME-v"$VERSION"U-AROMA_"$DATE"_"$VARIANT".zip $NZIPS/
  cd $CDF
  echo -e "$LCYAN$BLD ## Flasheable zip for $VARIANT Ready! ##$RATT"
  echo " "
}

VARIANT=d850; if [ $MAKED850 = 1 ]; then makezip; fi
VARIANT=d851; if [ $MAKED851 = 1 ]; then makezip; fi
VARIANT=d852; if [ $MAKED852 = 1 ]; then makezip; fi
VARIANT=d855; if [ $MAKED855 = 1 ]; then makezip; fi
VARIANT=ls990; if [ $MAKELS990 = 1 ]; then makezip; fi
VARIANT=vs985; if [ $MAKEVS985 = 1 ]; then makezip; fi
VARIANT=f400; if [ $MAKEF400 = 1 ]; then makezip; fi
VARIANT=dualsim; if [ $MAKEDUALSIM = 1 ]; then makezip; fi

echo -e "$GREEN$BLD Building Zips Done$RATT"
echo " "
}
