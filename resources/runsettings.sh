#!/bin/bash

# Session settings
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Check if theres a firstrun file, if not, execute the firstrun script
if [ ! -f $CDF/resources/other/firstrun ]; then
  log -t "RunSettings: Starting first run process..." $KBELOG
  source $CDF/resources/firstrun.sh
  return 1
fi

# Clear Variables (Just in case)
log -t "RunSettings: Clearing variables" $KBELOG
unset KERNELNAME; unset TARGETANDROID; unset VERSION; unset VARIANT;
unset BLDTYPE; unset P; unset; unset CLR; unset ARMT; unset ARCH;
unset BTYPE; unset AKBO; unset KDEBUG; unset RD; unset RELEASETYPE;

checkfolders --silent  # Check environment folders silently
checksource;           # Check if theres a Kernel source to work with
if [ "$CWK" = "n" ]; then return 1; fi

#-------------------------
# Script Functions 
#-------------------------

# Essencial Data
function promptdata() {
  unset ERR
  # Prompt for data
  echo -e "$WHITE  -------------------------"
  echo -e "$THEME$BLD - Enter your Kernel Information:"
  echo -e "$WHITE  -------------------------"
  echo " "
  read -p "   Kernel Name: " KERNELNAME; export KERNELNAME; log -t "RunSettings: Kernel name: $KERNELNAME" $KBELOG; if [ "$KERNELNAME" = "" ]; then ERR=1; return 1; fi
  if [ -f $CORED/$KERNELNAME.dev ]; then
    echo -ne "   Load last settings for $THEME$BLD$KERNELNAME$WHITE? [Y/N]: "; read LLS; log -t "RunSettings: '$KERNELNAME' last config found" $KBELOG
    if [ "$LLS" = "Y" ] || [ "$LLS" = "y" ]; then
      log -t "RunSettings: Loading '$KERNELNAME' last config" $KBELOG
      source $CORED/$KERNELNAME.dev
      unset LLS
      getcc
      export RD=1
      ERR=1
      return 1
    else
      log -t "RunSettings: User decided not to load last '$KERNELNAME' config, removing it" $KBELOG
      rm $CORED/$KERNELNAME.dev
    fi
  fi
  read -p "   Target Android OS: " TARGETANDROID; export TARGETANDROID; log -t "RunSettings: Target OS: $TARGETANDROID" $KBELOG;  if [ "$TARGETANDROID" = "" ]; then ERR=1; return 1; fi
  read -p "   Version: " VERSION; export VERSION; log -t "RunSettings: Version: $VERSION" $KBELOG;  if [ "$VERSION" = "" ]; then ERR=1; return 1; fi
  read -p "   Release Type ( 1 = Stable; 2 = Beta ): " RELEASETYPE; if [ "$RELEASETYPE" = "" ]; then ERR=1; return 1; fi
  if [ "$RELEASETYPE" = "1" ]; then RELEASETYPE="Stable"; elif [ "$RELEASETYPE" = "2" ]; then RELEASETYPE="Beta"; fi; export RELEASETYPE
  log -t "Runsettings: Release Type: $RELEASETYPE" $KBELOG
};

# Arch selection
function getarch() {
  # Get the ARCH Type
  echo -e "$WHITE  -------------------------"
  echo -e "$THEME$BLD - ARCH Type Selection:"
  echo -e "$WHITE  -------------------------"
  echo " "
  echo -e "$THEME$BLD   Choose ARCH Type ($WHITE 1 = 32Bits Devices; 2 =  64Bits Devices $THEME$BLD) $WHITE"
  until [ "$ARMT" = "1" ] || [ "$ARMT" = "2" ]; do
    read -p "   Your option [1/2]: " ARMT
    if [ "$ARMT" != "1" ] && [ "$ARMT" != "2" ]; then
      echo " "
      echo -e "$RED$BLD   Error, invalid option, try again..."
      echo -e "$WHITE"
    fi
  done
  case $ARMT in
       "1") export ARCH=arm; log -t "RunSettings: ARCH=arm" $KBELOG ;;
       "2") export ARCH=arm64; log -t "RunSettings: ARCH=arm64" $KBELOG ;;
  esac 
};

# Download CC Based on Arch
function getcc() {
  # This will export the correspondent CrossCompiler for the ARCH Type
  if [ "$ARCH" = "arm" ]; then
    CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi- # arm CrossCompiler
    log -t "RunSettings: Exported CROSSCOMPILE to $CROSSCOMPILE" $KBELOG
    # Check
    if [ ! -f "$CROSSCOMPILE"gcc ]; then
      log -t "RunSettings: CrossCompiler not found, downloading it..." $KBELOG
      echo -ne "$WHITE   Downloading the$THEME$BLD ARM$WHITE CrossCompiler$THEME$BLD (22.35MB, 'Ctrl + C' to Cancel)..."
      git clone https://github.com/KB-E/gcc-$ARCH $CDF/resources/crosscompiler/$ARCH/ &> /dev/null
      echo -e "$WHITE Done"; log -t "RunSettings: Done" $KBELOG; echo " "
    fi
  elif [ "$ARCH" = "arm64" ]; then
    CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-
    log -t "RunSettings: Exported CROSSCOMPILE to $CROSSCOMPILE" $KBELOG
    # Check 
    if [ ! -f "$CROSSCOMPILE"gcc ]; then
      log -t "RunSettings: CrossCompiler not found, downloading it..." $KBELOG
      echo -ne "$WHITE   Downloading the$THEME$BLD ARM64$WHITE CrossCompiler$THEME$BLD (144.20MB, 'Ctrl + C' to Cancel)..."
      git clone https://github.com/KB-E/linaro-$ARCH $CDF/resources/crosscompiler/$ARCH/ &> /dev/null
      echo -e "$WHITE Done"; log -t "RunSettings: Done" $KBELOG; echo " "
    fi
  fi
};

# Kernel Config
function getkconfig() {
  unset ERR
  echo -e "$WHITE  -------------------------"
  echo -e "$THEME$BLD - Kernel Selection and Config:"
  echo -e "$WHITE  -------------------------"
  echo " "
  cd $CDF/source; log -t "RunSettings: Entered in $CDF/source" $KBELOG
  select d in */; do test -n "$d" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
  if [ $ARCH = arm64 ] && [ ! -d $CDF/source/$d/arch/$ARCH/ ]; then
    echo " "
    echo -e "$RED$BLD   This Kernel Source doesn't contains 64bits defconfigs... Exiting...$RATT"
    echo " "; log -t "RunSettings: This kernel source doesnt contains 64bits defconfig, exiting KB-E..." $KBELOG
    cd $CDF
    export CWK=n
    ERR=1
    return 1
  fi
  if [ $ARCH = arm ] && [ ! -d $CDF/source/$d/arch/$ARCH/ ]; then
    echo " "
    echo -e "$RED$BLD   This Kernel Source doesn't contains 32bits defconfigs... Exiting...$RATT"
    echo " "; log -t "RunSettings: This kernel source doesnt contains 32bits defconfig, exiting KB-E..." $KBELOG
    cd $CDF
    export CWK=n
    ERR=1
    return 1
  fi
  cd $CDF
  export P=$CDF/source/$d; log -t "RunSettings: Exported kernel source to $P" $KBELOG
  echo " "
  echo -ne "   Debug Kernel Building?$THEME$BLD [Y/N]:$WHITE "
  read KDEBUG
  if [ $KDEBUG = y ] || [ $KDEBUG = Y ]; then
    export KDEBUG=1; log -t "RunSettings: Kernel debug enabled" $KBELOG
  fi

  # Variant and Defconfig 
  unset UDF
  if [ -f $OTHERF/variants.sh ]; then
    log -t "RunSettings: Lastest defined multi variants found" $KBELOG 
    echo -ne "   Use lastest defined variants?$THEME$BLD [Y/N]:$WHITE "
    read UDF
    if [ "$UDF" = y ] || [ "$UDF" = Y ]; then
      echo -e "   Using lastest defined variants..."; log -t "RunSettings: Using lastest defined multi variants" $KBELOG
      bash $OTHERF/variants.sh
      UDF=1
    else
      log -t "RunSettings: Skipping lastest defined multi variants" $KBELOG
    fi
  fi
  if [ "$UDF" != "1" ]; then
    until [ "$VARIANT1" != "" ]; do
      echo -ne "   Device Variant $THEME$BLD($WHITE Device Codename, e.g., 'bacon'$THEME$BLD ):$WHITE "
      read VARIANT1; export VARIANT1; log -t "RunSettings: Variant: $VARIANT1 defined" $KBELOG
      if [ "$VARIANT1" = "" ]; then
        echo " "
        echo -e "$RED$BLD   Please write device variant (Device codename or device name)$WHITE"
        echo " "
      fi
    done
    echo -e "   Select a Defconfig $THEME$BLD($WHITE Device Config File, e.g., 'bacon_defconfig'$THEME$BLD ):$WHITE "
    echo " "
    cd $P/arch/$ARCH/configs/; log -t "RunSettings: Entered in $P/arch/$ARCH/configs" $KBELOG
    select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
    cd $CDF
    export DEFCONFIG1=$DEF; log -t "RunSettings: Defconfig: $DEFCONFIG1" $KBELOG
    echo " "
    echo -ne "   Add more Variants?$THEME$BLD [Y/N]:$WHITE "
    read ADDMV
    if [ "$ADDMV" = y ] || [ "$ADDMV" = Y ]; then
      log -t "RunSettings: Adding more variants and defconfigs..." $KBELOG
      X=1
      if [ ! -f $VF ]; then
        log -t "RunSettings: Creating variants file" $KBELOG
        touch $VF
        echo "export VARIANT$X=$VARIANT1" > $VF
        echo "export DEFCONFIG$X=$DEF" >> $VF
      else
        log -t "RunSettings: Removing last variants file and creating it again" $KBELOG
        rm $VF
        touch $VF
        echo "export VARIANT$X=$VARIANT1" > $VF
        echo "export DEFCONFIG$X=$DEF" >> $VF
      fi
      bool=true
      while [ "$bool" = true ]; do
        X=$((X+1))
        read -p "   Variant $X: " VV
        if [ "$VV" = "" ]; then
          export bool=false
        else
          export VARIANT$X=$VV; log -t "RunSettings: Exported additional Variant: $VV" $KBELOG
          echo "export VARIANT$X=$VV" >> $VF
          echo -e "   Choose a defconfig:"
          cd $P/arch/$ARCH/configs/
          select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED>>> Invalid Selection$WHITE"; echo " "; done
          cd $CDF
          export DEFCONFIG$X=$DEF; log -t "RunSettings: Exported additional Defconfig: $DEF" $KBELOG
          echo "export DEFCONFIG$X=$DEF" >> $VF
        fi
      done
    fi
  fi
  # Clear source on each build?
  echo -ne "   Clear Source on every Build?$THEME$BLD [Y/N]:$WHITE "
  read CLRS
  if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
    log -t "RunSettings: Cleaning source on every build" $KBELOG
    export CLR=1
  fi
};

# Save all data
function saveconfig() {
  export DFILE=$CORED/$KERNELNAME.dev
  if [ ! -f $DFILE ]; then
    touch $DFILE; log -t "RunSettings: Created $DFILE" $KBELOG
  fi; log -t "RunSettings: Running writecoredevice..." $KBELOG
  writecoredevice
};

# Modules function
function getmodules() {
  log -t "RunSettings: Entering modules selection" $KBELOG
  echo -e "$WHITE  --------------------------"
  echo -e "$THEME$BLD   Modules selection:"
  echo -e "$WHITE  --------------------------"
  if [ -f $MLIST ]; then
    log -t "RunSettings: Removing $MLIST file" $KBELOG
    rm $MLIST
  fi
  log -t "RunSettings: Creating $MLIST file" $KBELOG
  touch $MLIST
  echo "# Modules Functions" > $MLIST
  k=1
  x=1
  for i in $CDF/modules/*.sh
  do
    echo " "
    echo -e "$WHITE  --------$THEME$BLD MODULE$WHITE --------"
    echo " "
    echo -e "$THEME$BLD   Name:$WHITE $(grep MODULE_NAME $i | cut -d '=' -f2)"
    echo -e "$THEME$BLD   Version:$WHITE $(grep MODULE_VERSION $i | cut -d '=' -f2)"
    echo -e "$THEME$BLD   Description:$WHITE $(grep MODULE_DESCRIPTION $i | cut -d '=' -f2)"
    #echo -e "$THEME$BLD   Priority:$WHITE $(grep MODULE_PRIORITY $i | cut -d '=' -f2)"
    echo " "
    echo -e "$WHITE  ------------------------"
    echo " "
    echo -ne "$THEME$BLD   Enable:$WHITE $(grep MODULE_NAME $i | cut -d '=' -f2)? [Y/N]: "
    read  EM
    if [ "$EM" = y ] || [ "$EM" = Y ]; then
      log -t "RunSettings: Module '$(grep MODULE_NAME $i | cut -d '=' -f2)' enabled" $KBELOG
      echo "export MODULE$((k))=$(grep MODULE_FUNCTION_NAME $i | cut -d '=' -f2)" >> $MLIST
      echo "export MPATH$((x))=$i" >> $MLIST
      echo "export MODULE$((k++))=$(grep MODULE_FUNCTION_NAME $i | cut -d '=' -f2)" >> $DFILE
      echo "export MPATH$((x++))=$i" >> $DFILE
      log -t "RunSettings: Running '$(grep MODULE_NAME $i | cut -d '=' -f2)' module" $KBELOG
      source $i
      # Execute module on device kernel file
      echo "source $i" >> $DFILE
    fi
  done
  log -t "RunSettings: Exporting modules configuration" $KBELOG
  source $MLIST
  log -t "RunSettings: Done" $KBELOG
};

# Lets start the config process here

promptdata; if [ "$ERR" = "1" ]; then unset ERR; return 1; fi; echo " "
getarch; echo " "
getcc;
getkconfig; if [ "$ERR" = "1" ]; then unset ERR; return 1; fi
saveconfig; echo " "
getmodules;

# Config process done
export RD=1
echo " "; log -t "RunSettings: Config done, displaying 'kbe' command usage to user" $KBELOG
echo -e "$WHITE  --------$THEME$BLD CONFIG DONE$WHITE --------"
echo " "
echo -e "$THEME$BLD - Usage:$WHITE kbe --kernel or -k $THEME$BLD(Builds the kernel)$WHITE"
echo -e "              --dtb or -dt $THEME$BLD(Builds device tree image)$WHITE"
i=1
while var=MODULE$((i++)); [[ ${!var} ]]; do
  path=MPATH$(($i-1)); [[ ${!path} ]];
  echo -e "              --${!var} $THEME$BLD($(grep MODULE_DESCRIPTION ${!path} | cut -d '=' -f2))$WHITE"
done
echo " "
echo -e "              --all $THEME$BLD(Does everything mentioned above)      $WHITE  | Work alone "
echo " "
echo -e "   For more information use $THEME$BLD'kbhelp'$WHITE command"
echo " "
echo -e "$WHITE  --------------------------$THEME$BLD"
echo " "
read -p "   Press enter to continue..."
log -t "RunSettings: All done" $KBELOG
echo -ne "$WHITE"
