#!/bin/bash

# Session settings
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Check if theres a firstrun file, if not, execute the firstrun script
if [ ! -f $CDF/resources/other/firstrun ]; then
  . $CDF/resources/firstrun.sh
  return 1
fi

# Clear Variables (Just in case)
unset KERNELNAME; unset TARGETANDROID; unset VERSION; unset VARIANT;
unset BLDTYPE; unset P; unset; unset CLR; unset ARMT; unset ARCH;
unset BTYPE; unset AKBO; unset KDEBUG; unset RD

if [ ! -d $CDF/source/* ]; then
echo " "
echo -e "$RED - No Kernel Source Found...$BLD (Kernel source goes into 'source' folder)$RATT"
CWK=n
echo " "
return 1
fi

# Prompt for data
echo " "
echo -e "$GREEN$BLD - Please, enter the necessary data for this session...$WHITE"
echo " "
read -p "   Kernel Name: " KERNELNAME; export KERNELNAME; if [ "$KERNELNAME" = "" ]; then return 1; fi
read -p "   Target Android OS: " TARGETANDROID; export TARGETANDROID;  if [ "$TARGETANDROID" = "" ]; then return 1; fi
read -p "   Version: " VERSION; export VERSION;  if [ "$VERSION" = "" ]; then return 1; fi

#read -p "   Number of Compiling Jobs: " NJOBS; export NJOBS

#until [ "$BLDTYPE" = A ] || [ "$BLDTYPE" = K ]; do
#  read -p "   Enter Build Type (A = AROMA; K = AnyKernel): " BLDTYPE
#  if [ $BLDTYPE != A ] && [ $BLDTYPE != K ]; then
#    echo " "
#    echo -e "$RED - Error, invalid option, try again..."
#    echo -e "$WHITE"
#  fi
#done
BLDTYPE=K # Aroma is still not available

# Get the ARCH Type
echo " "
echo -e "$GREEN$BLD - Choose ARCH Type ($WHITE 1 = 32Bits Devices; 2 =  64Bits Devices $GREEN$BLD) $WHITE"
until [ "$ARMT" = "1" ] || [ "$ARMT" = "2" ]; do
  read -p "   Your option [1/2]: " ARMT
  if [ "$ARMT" != "1" ] && [ "$ARMT" != "2" ]; then
    echo " "
    echo -e "$RED$BLD - Error, invalid option, try again..."
    echo -e "$WHITE"
  fi
done
if [ "$ARMT" = "1" ]; then
  export ARCH=arm
elif [ "$ARMT" = "2" ]; then
  export ARCH=arm64
fi

# This will export the correspondent CrossCompiler for the ARCH Type
if [ "$ARCH" = "arm" ]; then
  CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi- # arm CrossCompiler
  # Check
  if [ ! -f "$CROSSCOMPILE"gcc ]; then
  echo " "
  echo -e "$GREEN$BLD - Downloading the $ARCH CrossCompiler...$WHITE"
  git clone https://github.com/KB-E/gcc-$ARCH $CDF/resources/crosscompiler/$ARCH/
  echo -e "$WHITE Done"
  fi
elif [ "$ARCH" = "arm64" ]; then
  CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-
  # Check 
  if [ ! -f "$CROSSCOMPILE"gcc ]; then
  echo " "
  echo -e "$GREEN$BLD - Downloading the $ARCH CrossCompiler...$WHITE"
  git clone https://github.com/KB-E/linaro-$ARCH $CDF/resources/crosscompiler/$ARCH/
  echo -e "$WHITE Done"
  fi
fi

# AnyKernel Source Select
if [ "$BLDTYPE" = "K" ]; then
  BTYPE=AnyKernel
echo " "
echo -e "$GREEN$BLD - Choose an option for $BTYPE Installer: "
echo " "
echo -e "$WHITE   1) Use local $GREEN$BLD$BTYPE$WHITE Template"
echo -e "   2) Select a template from your 'templates' folder"
echo -e "   3) Let me manually set my template"
echo " "
until [ "$AKBO" = "1" ] || [ "$AKBO" = "3" ]; do
  read -p "   Your option [1/2/3]: " AKBO
  if [ "$AKBO" != "1" ] && [ "$AKBO" != "2" ] && [ "$AKBO" != "3" ]; then
    echo " "
    echo -e "$RED$BLD - Error, invalid option, try again..."
    echo -e "$WHITE"
  fi
  if [ "$AKBO" = "2" ]; then
    if [ ! -f $UTF/*/anykernel.sh ]; then
      echo " "
      echo -e "$RED$BLD There isn't any template inside 'templates' folder, choose other option$RATT"
      echo " "
    else
      CURR=$(pwd)
      cd $UTF
      select d in */; do test -n "$d" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
      cd $CURR; unset CURR
      export TF=$UTF/$d
      break
    fi
  fi
done

if [ "$AKBO" = "1" ]; then
  # Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
  export TF=$AKT
  # If this file is missing we can assume that we need to restore this template
  if [ ! -f $AKT/anykernel.sh ]; then
  checkfolders
  templatesconfig
  fi
fi

if [ "$AKBO" = "3" ]; then
  # Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
  export TF=$AKT
fi
fi

echo " "
echo -e "$GREEN$BLD - Select a Kernel Source folder...$WHITE"
cd $CDF/source
select d in */; do test -n "$d" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
if [ $ARCH = arm64 ] && [ ! -d $CDF/source/$d/arch/$ARCH/ ]; then
  echo " "
  echo -e "$RED$BLD - This Kernel Source doesn't contains 64bits defconfigs... Exiting...$RATT"
  echo " "
  cd $CDF
  export CWK=n
  return 1
fi
if [ $ARCH = arm ] && [ ! -d $CDF/source/$d/arch/$ARCH/ ]; then
  echo " "
  echo -e "$RED$BLD - This Kernel Source doesn't contains 32bits defconfigs... Exiting...$RATT"
  echo " "
  cd $CDF
  export CWK=n
  return 1
fi
cd $CDF
echo -e "$WHITE"
P=$CDF/source/$d
read -p "   Debug Kernel Building? [y/n]: " KDEBUG
if [ $KDEBUG = y ] || [ $KDEBUG = Y ]; then
  export KDEBUG=1
fi
echo " "

# Variant and Defconfig 
unset UDF
if [ -f $OTHERF/variants.sh ]; then
  read -p "   Use lastest defined variants? [y/n]: " UDF
  if [ "$UDF" = y ] || [ "$UDF" = Y ]; then
    echo -e "   Using lastest defined variants..."
    . $OTHERF/variants.sh
    UDF=1
  fi
fi
if [ "$UDF" != "1" ]; then
  until [ "$VARIANT1" != "" ]; do
    read -p "   Device Variant: " VARIANT1; export VARIANT1
    if [ "$VARIANT1" = "" ]; then
      echo " "
      echo -e "$RED$BLD   Please write device variant (Device codename or device name)$WHITE"
      echo " "
    fi
  done
  echo -e "   Select a Defconfig: " 
  cd $P/arch/$ARCH/configs/
  select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
  cd $CDF
  export DEFCONFIG1=$DEF
  echo " "
  read -p "   Add more Variants? [y/n]: " ADDMV
  if [ "$ADDMV" = y ] || [ "$ADDMV" = Y ]; then
    X=1
    VF=$OTHERF/variants.sh
    if [ ! -f $VF ]; then
      touch $VF
      echo "export VARIANT$X=$VARIANT1" > $VF
      echo "export DEFCONFIG$X=$DEF" >> $VF
    else
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
        export VARIANT$X=$VV
        echo "export VARIANT$X=$VV" >> $VF
        echo -e "   Choose a defconfig:"
        cd $P/arch/$ARCH/configs/
        select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED>>> Invalid Selection$WHITE"; echo " "; done
        cd $CDF
        export DEFCONFIG$X=$DEF
        echo "export DEFCONFIG$X=$DEF" >> $VF
      fi
    done
  fi
fi

echo " "
read -p "   Make dt.img? (Device Tree Image) [y/n]: " MKDTB
if [ "$MKDTB" = "y" ] || [ "$MKDTB" = "Y" ]; then
  export MAKEDTB=1
fi

read -p "   Clear Source on every Build? [y/n]: " CLRS
if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
  export CLR=1
fi

echo " "
export RD=1
echo -e "$GREEN$BLD - Config Done, now you can start Building! $WHITE"
echo -e "   If you need help run 'kbhelp' or see './README.md' file for more information"
echo " "
read -p "   Press enter to continue..."
