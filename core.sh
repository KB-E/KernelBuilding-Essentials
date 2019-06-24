#!/bin/bash

# Main Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>
# KB-E Version
KBV=3.0

# Only run with bash
if readlink /proc/$$/exe | grep -q "dash"; then
  echo "This script needs to be run with source or '.', not sh"
  exit
fi

#-------------------------------------------------------------------------
# If this is the first time running core.sh, install KB-E into environment
#-------------------------------------------------------------------------
# Don't run if core.sh is not found in the current path
if [ ! -f core.sh ] && [ "$1" != "--kbe" ]; then
  echo "Error: Please run core.sh inside the KB-E repo"
  return 1
fi
# Start the installation process
if [ ! -f ./resources/other/firstrun ] && [ "$1" != "--kbe" ]; then
  echo " "
  echo -e " - Disclaimer: "
  echo " "
  echo -e "   This Software will ask for sudo to download and install required"
  echo -e "   programs and tools, also, to chmod and chown neccesary files for the"
  echo -e "   correct functioning of all the code, I'm not responsable if this"
  echo -e "   program breaks your PC (which it shouldn't be able). We'll now"
  echo -e "   proceed to the first run of this program after your authorization..."
  echo " "
  read -p " - Do you agree the above disclaimer and continue? [Y/N]: " DAG
  echo " "
  if [ "$DAG" != "y" ] && [ "$DAG" != "Y" ]; then
    return 1
  fi
  read -p "   Thanks, good luck with your builds! Press enter to continue..."
  echo " "
  # Set permissions
  sudo chown -R $USER:users *
  # Get actual path
  CDF=$(pwd)
  # Set environment folders
  source $CDF/resources/other/checkfolders.sh
  checkfolders
  # Logging script
  source $CDF/resources/log.sh
  export KBELOG=$CDF/resources/logs/kbessentials.log
  log -t " " $KBELOG
  log -t "Installing KB-E..." $KBELOG
  # Load Colors
  source $CDF/resources/other/colors.sh
  log -t "Core: Colors loaded" $KBELOG
  source ./resources/install.sh
fi

# Main command, you'll tell here to the program what to do
function kbe() {
  # Instructions
  if [ "$1" = "" ]; then
    log -t "Displaying 'kbe' usage information" $KBELOG
    if [ "$RD" = "1" ]; then
      echo " "
      echo -e "$THEME$BLD - Usage:$WHITE kbe start $THEME$BLD(Starts KB-E Config process)$WHITE"
      echo -e "              start <kernelname> $THEME$BLD(Starts KB-E Config from a saved device file)$WHITE"
      echo -e "              clean $THEME$BLD(Wipes KB-E environment, except kernel sources)$WHITE"
      echo " "
      echo -e "              --kernel or -k $THEME$BLD(Builds the kernel)$WHITE"
      echo -e "              --dtb or -dt $THEME$BLD(Builds device tree image)$WHITE"
      i=1
      while
        var=MODULE$((i++))
        [[ ${!var} ]]
      do
        path=MPATH$(($i - 1))
        [[ ${!path} ]]
        echo -e "              --${!var} $THEME$BLD($(grep MODULE_DESCRIPTION ${!path} | cut -d '=' -f2))$WHITE"
      done
      echo " "
      echo -e "              --all $THEME$BLD(Does everything mentioned above)      $WHITE  | Work alone "
      echo " "
      echo -e "   For more information use $THEME$BLD'kbhelp'$WHITE command$RATT"
      echo " "
    else
      echo " "
      echo " - Usage: kbe start (Starts KB-E Config process)"
      echo "              start <kernelname> (Starts KB-E Config from a saved device file)"
      echo "              clean (Wipes KB-E environment, except kernel sources)"
      echo " "
    fi
  fi

  if [ "$1" = "start" ]; then
    # Set environment folders
    source $CDF/resources/other/checkfolders.sh
    CURR=$(pwd)
    checkfolders
    # Logging script
    source $CDF/resources/log.sh
    export KBELOG=$CDF/resources/logs/kbessentials.log
    log -t " " $KBELOG
    log -t "Starting KB-E..." $KBELOG

    # Load ProgramTools
    source $CDF/resources/programtools.sh
    log -t "Core: ProgramTools loaded" $KBELOG
    # Load SimpleTools
    source $CDF/resources/simpletools.sh
    log -t "Core: SimpleTools loaded" $KBELOG
    # Load title
    source $CDF/resources/other/programtitle.sh
    log -t "ProgramTitle loaded" $KBELOG

    # Start
    log -t "KB-E Version: $KBV" $KBELOG
    clear # Clear user UI
    unset CWK
    X=0
    until [ $X = 21 ]; do
      X=$((X + 1))
      unset VARIANT$X
    done

    # DisplayTitle
    title
    log -t "Displaying title" $KBELOG

    # Initialize KB-E Resources and Modules
    checktools
    log -t "Checking tools" $KBELOG
    log -t "LoadResources: Loading environment resources..." $KBELOG
    # Initialize KB-E Resources
    log -t "LoadResources: Loading variables..." $KBELOG
    source $CDF/resources/variables.sh
    log -t "LoadResources: Loading runsettings script" $KBELOG
    for i in $CDF/devices/*/; do
      if [ "$2" = "$(basename $i)" ]; then
        echo -e "   $THEME$BLD$(basename $i)$WHITE found in devices/ folder$RATT"
        source $i/"$(basename $i)".data
        RD=1
        NORS=1
      fi
    done
    if [ "$NORS" = "1" ]; then
      unset NORS
    else
      source $CDF/resources/runsettings.sh
      log -t "LoadResources: Loading buildkernel script" $KBELOG
    fi
    source $CDF/resources/buildkernel.sh
    log -t "LoadResources: Loading makedtb script" $KBELOG
    source $CDF/resources/makedtb.sh

    if [ "$CWK" = "n" ] || [ "$CWK" = "N" ]; then
      return 1
    fi
    echo " "

    # Clear some variables
    unset bool
    unset VV
    unset VARIANT
    unset DEFCONFIG
    unset X

    # Done
    if [ "$RD" = "1" ]; then
      echo -e "$THEME$BLD - Kernel-Building Essentials it's ready!$RATT"
      log -t "KB-E is Ready for its use" $KBELOG
      echo " "
    else
      # Remove incomplete device
      if [ -d $CDF/devices/$KERNELNAME ]; then
        rm -rf $CDF/devices/$KERNELNAME
      fi
      echo -e "$RED$BLD - Session cancelled$RATT"
      log -t "KB-E Session cancelled" $KBELOG
      echo " "
      unset RD
    fi
    log -f kbe $KBELOG
  fi

  # First of all, the program buildkernel and makedtb
  for g in $@; do
    if [ "$g" = "--kernel" ] || [ "$g" = "-k" ] && [ "$RD" = "1" ]; then
      log -t "Checking variants..." $KBELOG
      checkvariants
      if [ "$MULTIVARIANT" = "true" ]; then
        while
          var=VARIANT$((i++))
          [[ ${!var} ]]
        do
          def=DEFCONFIG$(($i - 1))
          [[ ${!def} ]]
          DEFCONFIG=${!def}
          VARIANT=${!var}
          log -t "Building Kernel for $VARIANT (def: $DEFCONFIG)" $KBELOG
          buildkernel
        done
      else
        VARIANT=$VARIANT1
        DEFCONFIG=$DEFCONFIG1
        log -t "Building Kernel for $VARIANT (def: $DEFCONFIG)" $KBELOG
        buildkernel
      fi
    fi
  done

  for s in $@; do
    if [ "$s" = "--dtb" ] || [ "$s" = "-dt" ] && [ "$RD" = "1" ]; then
      log -t "Checking variants..." $KBELOG
      checkvariants
      if [ "$MULTIVARIANT" = "true" ]; then
        while
          var=VARIANT$((i++))
          [[ ${!var} ]]
        do
          VARIANT=${!var}
          log -t "Building DTB for $VARIANT" $KBELOG
          makedtb
        done
      else
        VARIANT=$VARIANT1
        log -t "Building DTB for $VARIANT" $KBELOG
        makedtb
      fi
    fi
  done

  # Get and execute the modules
  for a in $@; do
    i=1
    while
      var=MODULE$((i++))
      [[ ${!var} ]]
    do
      path=MPATH$(($i - 1))
      [[ ${!path} ]]
      if [ "--$(grep MODULE_FUNCTION_NAME ${!path} | cut -d '=' -f2)" = "$a" ] && [ "$RD" = "1" ]; then
        EXEC=$(grep MODULE_FUNCTION_NAME ${!path} | cut -d '=' -f2)
        log -t "Executing '$(grep MODULE_NAME ${!path} | cut -d '=' -f2)' Module..." $KBELOG
        $EXEC
      fi
    done
  done
}
