#!/bin/bash

# Main Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>
# KB-E Version
KBV=4.2
REV=15

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
      echo -e "              start <device> $THEME$BLD(Starts KB-E Config from a saved device)$WHITE"
      echo -e "              clean $THEME$BLD(Wipes KB-E environment, except kernel sources)$WHITE"
      echo -e "              update <setting> <newvalue> $THEME$BLD(Update a specific setting of the current kernel)$WHITE"
      echo -e "              upgrade $THEME$BLD(Upgrade KB-E to the latest version/changes)"
      echo " "
      echo -e "              --kernel or -k $THEME$BLD(Builds the kernel)$WHITE"
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
      echo "              upgrade (Upgrade KB-E to the latest version/changes)"
      echo " "
    fi
  fi

  if [ "$1" = "status" ] && [ ! -z "$VARIANT" ]; then
    echo " "
    echo -e "$THEME$BLD   --------------------------------------------"
    echo -e "$THEME$BLD - Currently working on device:$WHITE $VARIANT"
    echo -e "$THEME$BLD   Kernel name:$WHITE $KERNELNAME"
    echo -e "$THEME$BLD   Target Android:$WHITE $TARGETANDROID"
    echo -e "$THEME$BLD   Version:$WHITE $VERSION"
    echo -e "$THEME$BLD   Release Type:$WHITE $RELEASETYPE"
    echo -e "$THEME$BLD   --------------------------------------------"
    echo -e "$THEME$BLD   Arch Type:$WHITE $ARCH"
    echo -e "$THEME$BLD   --------------------------------------------"
    echo " "
    echo -e "$WHITE - To update these values run 'kbe update' for more information$RATT"
    echo " "
  fi

  # ---------------------------------
  # Get latest updates from KB-E repo
  # ---------------------------------
  if [ "$1" = "upgrade" ]; then
    if [ -f core.sh ]; then
      CDF=$(pwd)
      # git pull KB-E repo
      echo " "; echo "KB-E: Getting latest changes from the repository"
      git pull https://github.com/KB-E/KernelBuilding-Essentials
      source $CDF/resources/other/colors.sh
      export KBELOG=$CDF/resources/logs/kbessentials.log; source $CDF/resources/log.sh
      echo -n "KB-E: Loading Updater Script..."; source $CDF/resources/updates.sh; echo " Done"
      echo -n "KB-E: Loading programtool.sh..."; source $CDF/resources/programtools.sh; echo " Done"
      echo -n "KB-E: Generating new init file..."; kbepatch; echo " Done"
      echo -n "KB-E: Patching ~/.bashrc ..."; bashrcpatch; echo " Done"
      echo -n "KB-E: Reloading ~/.bashrc ..."; source ~/.bashrc; echo " Done"
      echo -n "KB-E: Checking Dependencies..."; checktools; echo " Done"
      echo " "
    else
      echo " "; echo "KB-E: Error, you must run this command inside kb-e folder"
      echo "KB-E: run 'cdkbe' and try again"; echo " "
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
    unset CWK; unset CLRS

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
    for c in $CDF/devices/*; do
      if [ "$2" = "$(basename $c)" ]; then
        DEVICE=$(basename $c)
        echo -e "   $THEME$BLD$DEVICE$WHITE device found...!$RATT"
        # Count directories in that device folder
        DNUMBER=$(find $CDF/devices/"$DEVICE"/* -maxdepth 0 -type d -print| wc -l)
        if [ "$DNUMBER" = "1" ]; then
          DATAFOLDER=$(basename $CDF/devices/$DEVICE/*)
          echo -e "$THEME$BLD   Info:$WHITE This device only contains one Kernel configured"
          echo -e "   $THEME$BLD$DATAFOLDER$WHITE found and sourced$RATT"
          # The name of the data folder is the "kernelname"
          # and inside that folder theres another "kernelname.data"
          KDPATH=$CDF/devices/$DEVICE/$DATAFOLDER/                 # Build Kernel Directory path
          KFPATH=$CDF/devices/$DEVICE/$DATAFOLDER/$DATAFOLDER.data # Build Kernel File path
        else
          echo -e "$THEME$BLD   Info:$WHITE This device has more than one Kernel configured"
          # If the user didn't specified the <kernelname> or is invalid, pick from list
          if [ -z "$3" ] || [ ! -d $CDF/devices/$DEVICE/$3 ]; then
            echo -e "   Please select one from the list"
            # Remember last path position
            CURF=$(pwd); cd $c
            # Make the list
            select kf in */; do test -n "$kf" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
            DATAFOLDER=$(basename $kf)
            # Head back
            cd $CURF; unset CURF
          # Else, if the <kernelname> provided by user exist, load it
          elif [ -d $CDF/devices/$DEVICE/$3 ]; then
            DATAFOLDER=$3
          fi
          echo -e "   $THEME$BLD$DATAFOLDER$WHITE sourced$RATT"
          KDPATH=$CDF/devices/$DEVICE/$DATAFOLDER                  # Build Kernel Directory Path
          KFPATH=$CDF/devices/$DEVICE/$DATAFOLDER/$DATAFOLDER.data # Build Kernel File path
        fi
        source $KFPATH # Source the device settings to KB-E environment
        export KDPATH  # Export the path for the saved Kernel directory path
        export KFPATH  # Export the path for the saved Kernel file path
        RD=1           # Mark KB-E as ready
        NORS=1         # Device found, don't run RS (runsettings.sh)
        # Clear some variables
        unset DATAFOLDER; unset DEVICE; unset DNUMBER; unset kf; unset c
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

    # --------------------
    # Done, KB-E is ready!
    # --------------------
    if [ "$RD" = "1" ]; then
     # Update kbe command completion
      updatecompletion
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
      echo "          - kdebug ( enabled | disabled )"
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
      # User wants his kernel... If it builds...
      log -t "Building Kernel for $VARIANT (def: $DEFCONFIG)" $KBELOG
      # Before start building, save the current folder path
      CURF=$(pwd)
      buildkernel
      # buildkernel process is done, head back to the previous path
      cd $CURF; unset CURF
      if [ "$BDTB" = "1" ]; then
        # User wants dtb
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
