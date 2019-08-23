#!/bin/bash

# Main Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>
# KB-E Version
KBV=3.0

# Make sure this scripts only runs with bash,
# for example: . core.sh or source core.sh
if readlink /proc/$$/exe | grep -q "dash"; then
  echo "This script needs to be run with source or '.', not sh"
  exit
fi

#------------------------------------------------------------------------------
# If this is the first time running core.sh, install KB-E into your environment
#------------------------------------------------------------------------------
# Don't run if core.sh is not found in the current path
# (To avoid path errors)
if [ ! -f core.sh ] && [ "$1" != "--kbe" ]; then
  echo "Error: Please run core.sh inside the KB-E repo"
  return 1
fi
# ------------------------------
# Start the installation process
# -----------------------------
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
  # If the user doesn't trust me, cry and exit >:(
  if [ "$DAG" != "y" ] && [ "$DAG" != "Y" ]; then
    return 1
  fi
  # Arigathanks
  read -p "   Thanks, good luck with your builds! Press enter to continue..."
  echo " "
  # Set permissions
  sudo chown -R $USER:users *
  # Get current full path to KB-E
  CDF=$(pwd)
  # Check and create KB-E Environment folders
  source $CDF/resources/other/checkfolders.sh
  checkfolders
  # Logging script
  source $CDF/resources/log.sh
  export KBELOG=$CDF/resources/logs/kbessentials.log
  # Title
  source $CDF/resources/other/programtitle.sh
  # Program Tools
  source $CDF/resources/programtools.sh
  log -t " " $KBELOG
  log -t "Installing KB-E..." $KBELOG
  # Load Colors
  source $CDF/resources/other/colors.sh
  log -t "Core: Colors loaded" $KBELOG
  source ./resources/install.sh
fi

# --------------------------------------------------------
# Main command, you'll tell here to the program what to do
# --------------------------------------------------------
function kbe() {
  # Show KB-E usage if user doesn't specifies an argument
  if [ "$1" = "" ]; then
    log -t "Displaying 'kbe' usage information" $KBELOG
    # Here shows full usage information if KB-E is ready
    if [ "$RD" = "1" ]; then
      echo " "
      echo -e "$THEME$BLD - Usage:$WHITE kbe start $THEME$BLD(Starts KB-E Config process)$WHITE"
      echo -e "              start <kernelname> $THEME$BLD(Starts KB-E Config from a saved device file)$WHITE"
      echo -e "              clean $THEME$BLD(Wipes KB-E environment, except kernel sources)$WHITE"
      echo -e "              update <setting> <newvalue> $THEME$BLD(Update a specific setting of the current kernel)$WHITE"
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
      # Here shows basic usage information if KB-E is not ready
      echo " "
      echo " - Usage: kbe start (Starts KB-E Config process)"
      echo "              start <kernelname> (Starts KB-E Config from a saved device file)"
      echo "              clean (Wipes KB-E environment, except kernel sources)"
      echo " "
    fi
  fi

  # ----------------------------
  # Start a new KB-E Session...!
  # ----------------------------
  if [ "$1" = "start" ]; then
    # Check for KB-E environment folders
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

    # -------
    # Go KB-E
    # -------
    log -t "KB-E Version: $KBV" $KBELOG
    clear # Clear user UI for KB-E Summoning
    unset CWK
    # Remove extra variants that might be exported
    X=0
    until [ $X = 21 ]; do
      X=$((X + 1))
      unset VARIANT$X
    done

    # DisplayTitle >:D
    title
    log -t "Displaying title" $KBELOG

    # Check KB-E dependencies
    checktools
    log -t "Checking tools" $KBELOG
    log -t "LoadResources: Loading environment resources..." $KBELOG

    # ---------------------------
    # Initialize KB-E environment
    # ---------------------------
    log -t "LoadResources: Loading variables..." $KBELOG
    source $CDF/resources/variables.sh
    log -t "LoadResources: Loading runsettings script" $KBELOG
    # Check for a stored device file specified by the user
    for i in $CDF/devices/*/*.data; do
      if [ "$2".data = "$(basename $i)" ]; then
        echo -e "   $THEME$BLD$(basename $i)$WHITE found in devices/ folder$RATT"
        source $i # Export the device settings to KB-E environment
        export KFILE=$i # Export the path for the stored device file that
                        # might be needed by other scripts/modules
        RD=1 # Mark KB-E as ready
        NORS=1 # Device found, don't run RS (runsettings.sh)
      fi
    done
    if [ "$NORS" = "1" ]; then
      unset NORS # We don't need to run RS (runsettings.sh), neither this variable
    else
      source $CDF/resources/runsettings.sh # Configure a new device
      log -t "LoadResources: Loading buildkernel script" $KBELOG
    fi
    # Load KB-E script with Kernel building instructions
    source $CDF/resources/buildkernel.sh
    log -t "LoadResources: Loading makedtb script" $KBELOG
    # Load KB-E script with DTB Image building instructions
    source $CDF/resources/makedtb.sh

    # Oh no! Something went wrong, mission failed
    if [ "$CWK" = "n" ] || [ "$CWK" = "N" ]; then
      return 1
    fi
    echo " "

    # Clear some filthy variables
    unset bool; unset VV; unset VARIANT; unset DEFCONFIG; unset X

    # --------------------
    # Done, KB-E is ready!
    # --------------------
    if [ "$RD" = "1" ]; then
      echo -e "$THEME$BLD - Kernel-Building Essentials it's ready!$RATT"
      log -t "KB-E is Ready for its use" $KBELOG
      echo " "
    else
      # --------------------
      # Else, mission failed
      # --------------------
      if [ -f $CDF/devices/$KERNELNAME/$KERNELNAME.data ]; then
        rm $CDF/devices/$KERNELNAME/$KERNELNAME.data
      fi
      echo -e "$RED$BLD - Session cancelled$RATT"
      log -t "KB-E Session cancelled" $KBELOG
      echo " "
      unset RD
    fi
    log -f kbe $KBELOG
  fi

  # ------------------------------
  # Update a saved device settings
  # ------------------------------
  if [ "$1" = "update" ]; then
    # Only run if KB-E is ready
    if [ -z "$KERNELNAME" ]; then
      return 1
    fi
    # If user didn't specified a setting, show usage
    if [ "$2" = "" ]; then
      echo " "
      echo "KB-E Update usage: kbe update <setting> <newvalue>"
      echo " "
      echo "Settings: - targetandroid (whatever)"
      echo "          - version (only numbers preferred)"
      echo "          - releasetype ( Beta | Stable )"
      echo "          - arch ( arm | arm64 )"
      echo "          - defconfig (Select from list if no newvalue)"
      echo " "
    else
      # If user specified a valid or invalid setting,
      # function "updatedevice" is now reponsible
      updatedevice $2 $3
    fi
  fi

  # -----------------------
  # Kernel, DTB and Modules
  # -----------------------
  # First of all, KB-E buildkernel and makedtb scripts, these
  # ones are top priority
  for g in $@; do
    if [ "$g" = "--kernel" ] || [ "$g" = "-k" ] && [ "$RD" = "1" ]; then
      log -t "Checking variants..." $KBELOG
      # Check if we have multiple variants
      checkvariants
      # If we have multiple variants, build kernel for each one
      # else, just build the kernel for the sole variant we have
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
          # Before start building, save the current folder path
          CURF=$(pwd)
          buildkernel
          # buildkernel process is done, head back to the previous path
          cd $CURF; unset CURF
        done
      else
        VARIANT=$VARIANT1
        DEFCONFIG=$DEFCONFIG1
        log -t "Building Kernel for $VARIANT (def: $DEFCONFIG)" $KBELOG
        # Before start building, save the current folder path
        CURF=$(pwd)
        buildkernel
        # buildkernel process is done, head back to the previous path
        cd $CURF; unset CURF
      fi
    fi
  done

  for s in $@; do
    if [ "$s" = "--dtb" ] || [ "$s" = "-dt" ] && [ "$RD" = "1" ]; then
      log -t "Checking variants..." $KBELOG
      # Check if we have multiple variants
      checkvariants
      # If we have multiple variants, build DTB Image for each one
      # else, just build the DTB Image for the sole variant we have
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

  # Get and execute the modules, it is important that each
  # module identifies itself, read README.md for how to
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
        # Before executing a module, save the current path
        CURF=$(pwd)
        $EXEC
        # Head back to the saved path
        cd $CURF; unset CURF
      fi
    done
  done
}
