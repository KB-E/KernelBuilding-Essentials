
#!/bin/bash

# Program tools functions
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Install Building Tools
installtools () {
  echo " "
  sudo apt-get update
  sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev device-tree-compiler ccache libc++-dev
  echo " "
}
export -f installtools

checktools () {
  if [ -f $CDF/resources/other/missingdeps ]; then
    rm $CDF/resources/other/missingdeps
  fi
  declare -a progtools=("git" "build-essential" "kernel-package" "fakeroot" "libncurses5-dev" "libssl-dev" "device-tree-compiler" "ccache" "libc++-dev")
  for i in "${progtools[@]}"
  do
    PROGRAMINST=$(dpkg -s "$i" | grep Status | cut -d ":" -f 2)
    if [ "$PROGRAMINST" != " install ok installed" ]; then
      echo -e "$RED$BLD   $i is Missing"
      touch $CDF/resources/other/missingdeps
      echo "$1" >> $CDF/resources/other/missingdeps
      MISSINGDEPS=1
    fi
  done
  if [ ! -f $CDF/resources/other/missingdeps ]; then
    echo -e "$WHITE - All Dependencies checked$GREEN$BLD (Pass)$RATT"
    echo " "
  fi
  if [ "$MISSINGDEPS" = "1" ]; then
    echo " "
    echo -e "$RED$BLD - Some Dependecies are missing, KB-E cannot initialize without then, proceed to install? [Y/N]"
    read INSTDEP
    if [ "$INSTDEP" = "y" ] || [ "$INSTDEP" = "Y" ]; then
      installtools
    else
      echo -e "$WHITE Exiting KB-E..."
      export CWK=N
    fi
  fi
}
export -f checktools

checkvariants () {
  if [ -z "$VARIANT2" ]; then
    # We have only one Variant to Build
    MULTIVARIANT=false
  else
    # We have more than one Variant to Build
    MULTIVARIANT=true
  fi
}
export -f checkvariants

checkfolders () {
  # Check environment folders and if one, some or all doesnt exist
  # create or restore it
  if [ "$1" != "--silent" ]; then
    echo " "
    echo -ne "$GREEN$BLD - Checking Enviroment Folders... "
  fi
  sleep 0.5
  folder () {
    if [ ! -d $CDF/$FD ]; then
      mkdir $CDF/$FD
    fi
  }
  FD=out; folder
  FD=out/Images; folder
  FD=out/dt; folder
  FD=source; folder
  FD=resources/logs; folder
  FD=resources/devices; folder
  unset FD
  if [ "$1" != "--silent" ]; then
    echo -e "$WHITE Done$RATT"
  fi
}
export -f checkfolders

# Help command
kbhelp () {
  nano $HFP
}
export -f kbhelp

loadresources () {
  # Initialize KB-E Resources
  . $CDF/resources/variables.sh
  . $CDF/resources/runsettings.sh
  . $CDF/resources/buildkernel/buildkernel.sh
  . $CDF/resources/buildkernel/makedtb.sh
  . $CDF/resources/other/writecoredevice.sh
}
export -f loadresources

# Check CrossCompiler
checkcc () {
  # CROSS_COMPILER
if [ ! -f "$CROSSCOMPILE"gcc ]; then
  echo -e "$RED$BLD   Cross Compiler not found ($CROSSCOMPILE) "
  export CERROR=1 # Tell to the program that the CrossCompiler isn't availible
else
  echo -e "$WHITE   Cross Compiler Found!"
  export CERROR=0 # Initialize CrossCompilerERROR Variable
fi
}
export -f checkcc

# Check DTB Tool
checkdtbtool () {
  echo " "
  if [ ! -f $DTB ]; then # Check local dtbTool
  echo -e "$RED$BLD   DTB Tool not found, continuing without it...$RATT$WHITE"
  NODTB=1
else
  # If you didn't removed it, dtb is fine
  echo -e "$WHITE   DTB Tool found"
fi
}
export -f checkdtbtool

# Check Zip Tool
checkziptool () {
  echo " "
if ! [ -x "$(command -v zip)" ]; then # C'mon, just install it with:
                                      # sudo apt-get install zip
  echo -e "$RED$BLD   Zip is not installed, Kernel installer Zip will not be build!$WHITE"
  echo " "
  read -p "   Install Zip Tool? [y/n]: " INSZIP
  if [ $INSZIP = Y ] || [ $INSZIP = y ]; then
    sudo apt-get install zip
  else
    export NOBZ=1 # Tell the Zip building function to cancel the opetarion
                  # because Zip tool is 100% necessary
  fi
else
  export NOBZ=0 # Well, you had it, nice!
  echo -e "$WHITE   Zip Tool Found! $RATT"
fi
}
export -f checkziptool

# Load auto.sh function into .bashrc
writeprogramconfig () {
  echo " "
  echo -ne "$GREEN$BLD - Writting KB-E Config in ~/.bashrc...$WHITE"
  sudo sed -i '/# Load auto.sh function and path/d' ~/.bashrc
  sudo sed -i '/CDF=/d' ~/.bashrc
  sudo sed -i '/colors.sh/d' ~/.bashrc
  sudo sed -i '/auto.sh/d' ~/.bashrc
  echo "# Load auto.sh function and path" >> ~/.bashrc
  echo "CDF=$CDF" >> ~/.bashrc
  echo ". $CDF/resources/other/colors.sh" >> ~/.bashrc
  echo ". $CDF/auto.sh" >> ~/.bashrc
  . $CDF/auto.sh
  echo -e " Done"
  echo " "
}
export -f writeprogramconfig
