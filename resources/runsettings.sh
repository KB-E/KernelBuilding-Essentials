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

checkfolders --silent
if [ -z "$(ls -A $CDF/source/)" ]; then
  echo -e "$RED - No Kernel Source Found...$BLD (Kernel source goes into 'source' folder)$RATT"
  CWK=n
  echo " "
  return 1
fi

# Prompt for data
echo " "
echo -e "$WHITE  -------------------------"
echo -e "$GREEN$BLD - Enter your Kernel Information:"
echo -e "$WHITE  -------------------------"
echo " "
read -p "   Kernel Name: " KERNELNAME; export KERNELNAME; if [ "$KERNELNAME" = "" ]; then return 1; fi
read -p "   Target Android OS: " TARGETANDROID; export TARGETANDROID;  if [ "$TARGETANDROID" = "" ]; then return 1; fi
read -p "   Version: " VERSION; export VERSION;  if [ "$VERSION" = "" ]; then return 1; fi
echo " "

# Get the ARCH Type
echo -e "$WHITE  -------------------------"
echo -e "$GREEN$BLD - CrossCompiler Selection:"
echo -e "$WHITE  -------------------------"
echo " "
echo -e "$GREEN$BLD   Choose ARCH Type ($WHITE 1 = 32Bits Devices; 2 =  64Bits Devices $GREEN$BLD) $WHITE"
until [ "$ARMT" = "1" ] || [ "$ARMT" = "2" ]; do
  read -p "   Your option [1/2]: " ARMT
  if [ "$ARMT" != "1" ] && [ "$ARMT" != "2" ]; then
    echo " "
    echo -e "$RED$BLD   Error, invalid option, try again..."
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
    echo -ne "$WHITE   Downloading the$GREEN$BLD ARM$WHITE CrossCompiler$GREEN$BLD (22.35MB, 'Ctrl + C' to Cancel)..."
    git clone https://github.com/KB-E/gcc-$ARCH $CDF/resources/crosscompiler/$ARCH/ &> /dev/null
    echo -e "$WHITE Done"
  fi
elif [ "$ARCH" = "arm64" ]; then
  CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-
  # Check 
  if [ ! -f "$CROSSCOMPILE"gcc ]; then
    echo " "
    echo -ne "$WHITE   Downloading the$GREEN$BLD ARM64$WHITE CrossCompiler$GREEN$BLD (144.20MB, 'Ctrl + C' to Cancel)..."
    git clone https://github.com/KB-E/linaro-$ARCH $CDF/resources/crosscompiler/$ARCH/ &> /dev/null
    echo -e "$WHITE Done"
  fi
fi
echo " "
echo -e "$WHITE  -------------------------"
echo -e "$GREEN$BLD - Kernel Selection and Config:"
echo -e "$WHITE  -------------------------"
echo " "
cd $CDF/source
select d in */; do test -n "$d" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
if [ $ARCH = arm64 ] && [ ! -d $CDF/source/$d/arch/$ARCH/ ]; then
  echo " "
  echo -e "$RED$BLD   This Kernel Source doesn't contains 64bits defconfigs... Exiting...$RATT"
  echo " "
  cd $CDF
  export CWK=n
  return 1
fi
if [ $ARCH = arm ] && [ ! -d $CDF/source/$d/arch/$ARCH/ ]; then
  echo " "
  echo -e "$RED$BLD   This Kernel Source doesn't contains 32bits defconfigs... Exiting...$RATT"
  echo " "
  cd $CDF
  export CWK=n
  return 1
fi
cd $CDF
P=$CDF/source/$d
echo " "
echo -ne "   Debug Kernel Building?$GREEN$BLD [Y/N]:$WHITE "
read KDEBUG
if [ $KDEBUG = y ] || [ $KDEBUG = Y ]; then
  export KDEBUG=1
fi

# Variant and Defconfig 
unset UDF
if [ -f $OTHERF/variants.sh ]; then
  echo -ne "   Use lastest defined variants?$GREEN$BLD [Y/N]:$WHITE "
  read UDF
  if [ "$UDF" = y ] || [ "$UDF" = Y ]; then
    echo -e "   Using lastest defined variants..."
    . $OTHERF/variants.sh
    UDF=1
  fi
fi
if [ "$UDF" != "1" ]; then
  until [ "$VARIANT1" != "" ]; do
    echo -ne "   Device Variant $GREEN$BLD($WHITE Device Codename, e.g., 'bacon'$GREEN$BLD ):$WHITE "
    read VARIANT1; export VARIANT1
    if [ "$VARIANT1" = "" ]; then
      echo " "
      echo -e "$RED$BLD   Please write device variant (Device codename or device name)$WHITE"
      echo " "
    fi
  done
  echo -e "   Select a Defconfig $GREEN$BLD($WHITE Device Config File, e.g., 'bacon_defconfig'$GREEN$BLD ):$WHITE "
  echo " "
  cd $P/arch/$ARCH/configs/
  select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
  cd $CDF
  export DEFCONFIG1=$DEF
  echo " "
  echo -ne "   Add more Variants?$GREEN$BLD [Y/N]:$WHITE "
  read ADDMV
  if [ "$ADDMV" = y ] || [ "$ADDMV" = Y ]; then
    X=1
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

echo -ne "   Make dt.img?$GREEN$BLD ($WHITE Device Tree Image, Recommended$GREEN$BLD ) [Y/N]:$WHITE "
read MKDTB
if [ "$MKDTB" = "y" ] || [ "$MKDTB" = "Y" ]; then
  export MAKEDTB=1
fi

echo -ne "   Clear Source on every Build?$GREEN$BLD [Y/N]:$WHITE "
read CLRS
if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
  export CLR=1
fi
echo " "
echo " "
echo -e "$WHITE  --------------------------"
echo -e "$GREEN$BLD   Modules selection:"
echo -e "$WHITE  --------------------------"
if [ -f $MLIST ]; then
  rm $MLIST
fi
touch $MLIST
echo "# Modules Functions" > $MLIST
k=1
x=1
for i in $CDF/modules/*.sh
do
  echo " "
  echo -e "$WHITE  --------$GREEN$BLD MODULE$WHITE --------"
  echo " "
  echo -e "$GREEN$BLD   Name:$WHITE $(grep MODULE_NAME $i | cut -d '=' -f2)"
  echo -e "$GREEN$BLD   Version:$WHITE $(grep MODULE_VERSION $i | cut -d '=' -f2)"
  echo -e "$GREEN$BLD   Description:$WHITE $(grep MODULE_DESCRIPTION $i | cut -d '=' -f2)"
#  echo -e "$GREEN$BLD   Priority:$WHITE $(grep MODULE_PRIORITY $i | cut -d '=' -f2)"
  echo " "
  echo -e "$WHITE  ------------------------"
  echo " "
  echo -ne "$GREEN$BLD   Enable:$WHITE $(grep MODULE_NAME $i | cut -d '=' -f2)? [Y/N]: "
  read  EM
  if [ "$EM" = y ] || [ "$EM" = Y ]; then
    echo "export MODULE$((k++))=$(grep MODULE_FUNCTION_NAME $i | cut -d '=' -f2)" >> $MLIST
    echo "export MPATH$((x++))=$i" >> $MLIST
    . $i
  fi
done
. $MLIST

export RD=1
echo " "
echo -e "$WHITE  --------$GREEN$BLD CONFIG DONE$WHITE --------"
echo " "
echo -e "$GREEN$BLD - Usage:$WHITE essentials --kernel $GREEN$BLD(Builds the kernel)$WHITE"
echo -e "                     --dtb $GREEN$BLD(Builds device tree image)$WHITE"
i=1
while var=MODULE$((i++)); [[ ${!var} ]]; do
  path=MPATH$(($i-1)); [[ ${!path} ]];
  echo -e "                     --${!var} $GREEN$BLD($(grep MODULE_DESCRIPTION ${!path} | cut -d '=' -f2))$WHITE"
done
echo " "
echo -e "                     --all $GREEN$BLD(Does everything mentioned above)      $WHITE  | Work alone "
echo " "
echo -e "   For more information use $GREEN$BLD'kbhelp'$WHITE command"
echo " "
echo -e "$WHITE  --------------------------$GREEN$BLD"

#echo " "
#echo -e "$GREEN$BLD - Config Done, now you can start running the 'essentials' command!  $WHITE"
#echo -e "   If you need help run 'kbhelp' or see './README.md' file for more information"
#echo " "
echo " "
read -p "   Press enter to continue..."
echo -ne "$WHITE"
