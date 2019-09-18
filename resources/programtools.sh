#!/bin/bash

# Program tools functions
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Install Building Tools
function installtools() {
  log -t "Installing dependencies..." $KBELOG
  echo " "
  sudo apt-get update
  sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev device-tree-compiler ccache libc++-dev gcc
  echo " "
  log -t "Dependencies installed" $KBELOG
}
export -f installtools; log -f installtools $KBELOG

function checktools() {
  log -t "CheckTools: Checking dependencies..." $KBELOG
  if [ -f $CDF/resources/other/missingdeps ]; then
    rm $CDF/resources/other/missingdeps;
  fi
  declare -a progtools=("git" "build-essential" "kernel-package" "fakeroot" "libncurses5-dev" "libssl-dev" "device-tree-compiler" "ccache" "libc++-dev")
  for i in "${progtools[@]}"
  do
    PROGRAMINST=$(dpkg -s "$i" | grep Status | cut -d ":" -f 2)
    if [ "$PROGRAMINST" != " install ok installed" ]; then
      echo -e "$RED$BLD   $i is Missing"; log -t "CheckTools: $1 is missing" $KBELOG
      touch $CDF/resources/other/missingdeps
      echo "$1" >> $CDF/resources/other/missingdeps
      MISSINGDEPS=1
    fi
  done
  if [ ! -f $CDF/resources/other/missingdeps ]; then
    echo -e "$WHITE - All Dependencies checked$THEME$BLD (Pass)$RATT"
    echo " "; log -t "CheckTools: All dependencies installed" $KBELOG
  fi
  if [ "$MISSINGDEPS" = "1" ]; then
    echo " "
    echo -e "$RED$BLD - Some Dependecies are missing, KB-E cannot initialize without then, proceed to install? [Y/N]"
    read INSTDEP
    if [ "$INSTDEP" = "y" ] || [ "$INSTDEP" = "Y" ]; then
      log -t "CheckTools: Installing missing dependencies..." $KBELOG
      installtools
      log -t "CheckTools: Done" $KBELOG
    else
      echo -e "$WHITE Exiting KB-E..."
      export CWK=N; log -t "CheckTools: User didn't wanted to install the missing dependencies, exiting KB-E..." $KBELOG
    fi
  fi
}
export -f checktools; log -f checktools $KBELOG

# Check if theres a kernel source
function checksource() {
  unset CWK
  for folder in $CDF/source/*; do
    if [ -f $folder/Makefile ]; then
      log -t "RunSettings: Kernel source found" $KBELOG
      return 1
    else
      echo -e "$RED - No Kernel Source Found...$BLD (Kernel source goes into 'source' folder)$RATT"
      log -t "RunSettings: Error, no kernel source found, exiting KB-E..." $KBELOG
      export CWK=n
      echo " "
      return 1
    fi
  done
}

# Help command
function kbhelp() {
  log -t "kbehelp: Displaying help file to user" $KBELOG
  nano $HFP;
}
export -f kbhelp; log -f kbhelp $KBELOG

# Check CrossCompiler
function checkcc() {
  log -t "CheckCC: Checking CrossCompiler..." $KBELOG
  # CROSS_COMPILER
if [ ! -f "$CROSSCOMPILE"gcc ]; then
  echo -e "$RED$BLD   Cross Compiler not found ($CROSSCOMPILE) "; log -t "CheckCC: CrossCompiler not found" $KBELOG
  export CERROR=1 # Tell to the program that the CrossCompiler isn't availible
else
  echo -e "$WHITE   Cross Compiler Found!"; log -t "CheckCC: CrossCompiler found" $KBELOG
  export CERROR=0 # Initialize CrossCompilerERROR Variable
fi
}
export -f checkcc; log -f checkcc $KBELOG

# Check DTB Tool
function checkdtbtool() {
  log -t "CheckDTBTool: Checking DTB Tool..." $KBELOG
  echo " "
  if [ ! -f $CDF/resources/dtbtool/dtbtool.c ]; then # Check local dtbTool
  echo -e "$RED$BLD   DTB Tool source not found$RATT$WHITE"; log -t "CheckDTBTool: DTB Tool source not found" $KBELOG
  echo -ne "$WHITE   Downloading from Github..."; log -t "CheckDTBTool: Downloading from Github..." $KBELOG
  git clone https://github.com/KB-E/dtbtool resources/dtbtool &> /dev/null
  echo -e "$THEME$BLD Done$RATT"; log -t "CheckDTBTool: Done" $KBELOG
else
  # If you didn't removed it, dtb is fine
  echo -e "$WHITE   DTB Tool source found"; log -t "CheckDTBTool: DTB Tool source found" $KBELOG
fi
}
export -f checkdtbtool; log -f checkdtbtool $KBELOG

# Check Zip Tool
function checkziptool() {
  log -t "CheckZipTool: Checking Zip tool..." $KBELOG
  echo " "
if ! [ -x "$(command -v zip)" ]; then # C'mon, just install it with:
                                      # sudo apt-get install zip
  echo -e "$RED$BLD   Zip is not installed, Kernel installer Zip will not be build!$WHITE"
  echo " "; log -t "CheckZipTool: Zip tool is not installed, Kernel installer will not be built" $KBELOG
  read -p "   Install Zip Tool? [y/n]: " INSZIP
  if [ $INSZIP = Y ] || [ $INSZIP = y ]; then
    log -t "CheckZipTool: Installing Zip tool..." $KBELOG
    sudo apt-get install zip
    log -t "CheckZipTool: Done" $KBELOG
  else
    export NOBZ=1 # Tell the Zip building function to cancel the opetarion
                  # because Zip tool is 100% necessary
  fi
else
  export NOBZ=0 # Well, you had it, nice!
  echo -e "$WHITE   Zip Tool Found! $RATT"; log -t "CheckZipTool: Zip tool found" $KBELOG
fi
}
export -f checkziptool; log -f checkziptool $KBELOG

function readfromdevice() {
  # Read and export the desired value from the device file
  case $1 in
    "targetandroid") export TARGETANDROID=$(grep TARGETANDROID $KFPATH | cut -d '=' -f2) ;;
          "version") export VERSION=$(grep VERSION $KFPATH | cut -d '=' -f2) ;;
      "releasetype") export RELEASETYPE=$(grep RELEASETYPE $KFPATH | cut -d '=' -f2) ;;
             "arch") export ARCH=$(grep ARCH $KFPATH | cut -d '=' -f2) ;;
     "crosscompile") export CROSSCOMPILE=$(grep CROSSCOMPILE $KFPATH | cut -d '=' -f2) ;;
            "kpath") export P=$(grep P $KFPATH | cut -d '=' -f2) ;;
           "kdebug") export KDEBUG=$(grep KDEBUG $KFPATH | cut -d '=' -f2) ;;
          "variant") export VARIANT=$(grep VARIANT $KFPATH | cut -d '=' -f2) ;;
        "defconfig") export DEFCONFIG=$(grep DEFCONFIG $KFPATH | cut -d '=' -f2) ;;
  esac
}
function updatedevice() {
  # Check if the user supplied a available setting and process it
  case $1 in
                     # Update targetandroid in devicefile
    "targetandroid") if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for targetandroid"; return 1; fi
                     readfromdevice targetandroid;
                     sed -i "s/export TARGETANDROID=$TARGETANDROID/export TARGETANDROID=$2/g" $KFPATH;
                     export TARGETANDROID=$2;
                     echo "KB-E: Update: targetandroid updated to '$2'"; return 1 ;;
                     # Update version in devicefile

          "version") if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for version"; return 1; fi
                     readfromdevice version;
                     sed -i "s/export VERSION=$VERSION/export VERSION=$2/g" $KFPATH;
                     export VERSION=$2;
                     echo "KB-E: Update: version updated to '$2'"; return 1 ;;

      "releasetype") # Update the release type
                     if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for releasetype"; return 1; fi
                     if [ "$2" = "Stable" ] || [ "$2" = "Beta" ]; then
                       readfromdevice releasetype
                       sed -i "s/export RELEASETYPE=$RELEASETYPE/export RELEASETYPE=$2/g" $KFPATH;
                       export RELEASETYPE=$2;
                       echo "KB-E: Update: releasetype updated to '$2'"; return 1;
                     else
                       echo "KB-E: Update: error, releasetype only accept 'Stable' or 'Beta' values";
                       return 1;
                     fi ;;

             "arch") # Update the arch type (this also includes the crosscompiler automatically)
                     if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for arch"; return 1; fi
                     if [ "$2" = "arm" ] || [ "$2" = "arm64" ]; then
                       readfromdevice arch
                       readfromdevice kpath
                       if [ "$2" = "arm" ] && [ ! -d $P/arch/$ARCH ]; then
                         echo "KB-E: Update: error, you are trying to switch to 'arm' but your source doesnt support it";
                         return 1
                       elif [ "$2" = "arm64" ] && [ ! -d $P/arch/$ARCH ]; then
                         echo "KB-E: Update: error, you are trying to switch to 'arm64' but your source doesnt support it";
                         return 1
                       fi
                       sed -i "s/export ARCH=$ARCH/export ARCH=$2/" $KFPATH;
                       export ARCH=$2;
                       echo "KB-E: Update: arch type updated to '$2'";
                       if [ "$2" = "arm" ]; then
                         readfromdevice crosscompile;
                         sed -i "s+export CROSSCOMPILE=$CROSSCOMPILE+export CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-linux-androideabi-+g" $KFPATH;
                         echo "KB-E: Update: crosscompile updated to arm to match arch type";
                         export CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-linux-androideabi-
                       elif [ "$2" = "arm64" ]; then
                         readfromdevice crosscompile;
                         sed -i "s+export CROSSCOMPILE=$CROSSCOMPILE+export CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-+g" $KFPATH;
                         echo "KB-E: Update: crosscompile updated to arm64 to match arch type";
                         export CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-
                       fi
                       return 1;
                     else
                       echo "KB-E: Update: error, arch type only accept 'arm' or 'arm64' values";
                       return 1;
                     fi ;;

        "defconfig") # Update the defconfig file
                     CURF=$(pwd)
                     readfromdevice arch; readfromdevice defconfig; #readfromdevice kpath;
                     if [ -z "$2" ]; then
                       echo "KB-E: Update: Select a defconfig:";
                       cd $P/arch/$ARCH/configs/;
                       select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
                       sed -i "s/export DEFCONFIG=$DEFCONFIG/export DEFCONFIG=$DEF/g" $KFPATH;
                       export DEFCONFIG=$DEF; unset DEF;
                       cd $CURF; unset CURF; echo "KB-E: Update: defconfig updated to '$DEFCONFIG'";
                       return 1;
                     fi
                     if [ -f $P/arch/$ARCH/configs/"$2" ]; then
                       sed -i "s/export DEFCONFIG=$DEFCONFIG/export DEFCONFIG=$2/g" $KFPATH;
                       export DEFCONFIG=$2;
                       echo "KB-E: Update: defconfig updated to '$2'"; return 1;
                     else
                       echo "KB-E: Update: supplied defconfig file name doesn't exist in kernel source";
                       return 1;
                     fi ;;

  esac

  # Anything else is not supported
  if [ ! -z "$1" ]; then
    echo "KB-E: Update: supplied setting '$1' is not supported"
    return 1
  fi
}

function bashrcpatch() {
  # Patch ~/.bashrc to load KB-E init file
  if grep -q "# Load KB-E init file" ~/.bashrc; then
    echo " "; echo -e "$THEME$BLD - ~/.bashrc is already patched..!$RATT"
  else
    log -t "Install: Patching ~/.bashrc" $KBELOG; echo " "
    echo -ne "$THEME$BLD - Patching ~/.bashrc to load init file...$WHITE"
    echo "# Load KB-E init file" >> ~/.bashrc
    echo "source $CDF/resources/init/init.sh" >> ~/.bashrc
    echo -e " Done$RATT"
  fi
}
export -f bashrcpatch

function kbepatch() {
  # Create a init file for KB-E
  INITPATH=$CDF/resources/init/init.sh
  if [ ! -f $INITPATH ]; then
    touch $INITPATH
  fi
  echo "#!/bin/bash" > $INITPATH
  echo "" >> $INITPATH
  echo "# KB-E init script" >> $INITPATH
  echo "# This is automatically generated, do not edit" >> $INITPATH
  echo "" >> $INITPATH
  echo "# Load KB-E Function and Path" >> $INITPATH
  echo "CDF=$CDF" >> $INITPATH
  echo "source $CDF/resources/other/colors.sh" >> $INITPATH
  echo "source $CDF/resources/log.sh" >> $INITPATH
  echo "source $CDF/core.sh --kbe" >> $INITPATH
  echo "complete -W 'start upgrade' kbe" >> $INITPATH
  echo "" >> $INITPATH
  echo "# Load configurable init script" >> $INITPATH
  echo "if [ -f $CDF/resources/init/kbeinit.sh ]; then" >> $INITPATH
  echo "  source $CDF/resources/init/kbeinit.sh" >> $INITPATH
  echo "fi" >> $INITPATH
}
export -f kbepatch

function updatecompletion() {
  # Update the completion for kbe command
  # Get all active modules
  X=1; module=MODULE$X
  unset moduleargs
  while :; do
    if [ -z "${!module}" ]; then
      break
    else
      moduleargs="$moduleargs --${!module}"
      ((X++))
      module=MODULE$X
    fi
  done
  complete -W "start clean update upgrade status help --kernel --dtb $moduleargs" kbe
}
