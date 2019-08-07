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

function checkvariants() {
  log -t "CheckVariants: Checking Multivariants..." $KBELOG
  if [ -z "$VARIANT2" ]; then
    # We have only one Variant to Build
    MULTIVARIANT=false; log -t "CheckVariants: Config is set for a single variant" $KBELOG
  else
    # We have more than one Variant to Build
    MULTIVARIANT=true; log -t "CheckVariants: Config is set for multiple variants" $KBELOG
  fi
}
export -f checkvariants; log -f checkvariants $KBELOG

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
