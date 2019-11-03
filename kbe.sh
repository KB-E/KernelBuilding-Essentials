#!/bin/bash
# Core Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# KB-E Version and Revision
VERSION=1.0; REVISION=1
# Make sure this scripts only runs with bash,
# for example: . core.sh or source core.sh
if readlink /proc/$$/exe | grep -q "dash"; then
  echo "This script needs to be run with source or '.', not sh"
  exit
fi
# Don't run if core.sh is not found in the current path
# (To avoid path errors)
if [ ! -f kbe.sh ] && [ "$1" != --init ]; then
  echo "Error: Please run kbe.sh inside the KB-E repo"
  return 1
fi

#--------------------------------------------
# If this is the first time running core.sh
# install KB-E into your environment
#--------------------------------------------
if [ ! -f resources/other/firstrun ] && [ "$1" != --init ]; then
  # Initialize the Pre-Installation Script
  unset agreed_disclaimer
  if [ ! -f logs/install_log.txt ]; then touch logs/install_log.txt; fi
  source resources/setup/preinstallation.sh |& tee logs/install_log.txt
  # If user didn't agreed to it, exit KB-E
  if [ "$agreed_disclaimer" = "false" ]; then
    return 1
  fi
  kbelog -t "KB-E: Pre-Installation is done"
  # Initialize the Installation Script
  source resources/setup/install.sh |& tee -a logs/install_log.txt
  kbelog -t "KB-E: Installation is done"
fi

# --------------------------------------------------------
# Main command, you'll tell here to the program what to do
# --------------------------------------------------------
function kbe() {
  # -----------------------------------------------------
  # Show KB-E usage if user doesn't specifies an argument
  # -----------------------------------------------------
  if [ "$1" = "" ]; then
    kbelog -t "Displaying 'kbe' usage information"
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

  # ----------------------------------
  # Show status for the current device
  # ----------------------------------
  if [ "$1" = "status" ] && [ ! -z "$device_variant" ]; then
    echo " "
    echo -e "$THEME$BLD   --------------------------------------------"
    echo -e "$THEME$BLD - Currently working on device:$WHITE $device_variant"
    echo -e "$THEME$BLD   Kernel name:$WHITE $kernel_name"
    echo -e "$THEME$BLD   Target Android:$WHITE $target_android"
    echo -e "$THEME$BLD   Version:$WHITE $kernel_version"
    echo -e "$THEME$BLD   Release Type:$WHITE $release_type"
    echo -e "$THEME$BLD   --------------------------------------------"
    echo -e "$THEME$BLD   Arch Type:$WHITE $kernel_arch"
    echo -e "$THEME$BLD   --------------------------------------------"
    echo " "
    echo -e "$WHITE - To update these values and more information run 'kbe update'$RATT"
    echo " "
  fi

  # ---------------------------------
  # Get latest updates from KB-E repo
  # ---------------------------------
  if [ "$1" = "upgrade" ]; then
    if [ -f kbe.sh ]; then
      # git pull KB-E repo
      echo " "; echo "KB-E: Getting latest changes from the repository"
      git pull https://github.com/KB-E/KernelBuilding-Essentials
      source resources/other/colors.sh
      source resources/log.sh
      echo -n "KB-E: Loading Updater Script..."; source resources/updates.sh; echo " Done"
      echo -n "KB-E: Loading programtool.sh..."; source resources/programtools.sh; echo " Done"
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

  # ----------
  # KB-E Theme
  # ----------
  if [ "$1" = "theme" ]; then
    # Start the themer
    kbe_themer "$2"
  fi

  # ----------------------------
  # Start a new KB-E Session...!
  # ----------------------------
  if [ "$1" = "start" ]; then
    # Log script 
    source $kbe_path/resources/log.sh
    kbelog -t " "; kbelog -t "Starting KB-E..."
    # Load ProgramTools
    source $kbe_path/resources/programtools.sh
    kbelog -t "KB-E: ProgramTools loaded" 
    # Load SimpleTools
    source $kbe_path/resources/simpletools.sh
    kbelog -t "KB-E: SimpleTools loaded" 
    # Load title
    source $kbe_path/resources/other/programtitle.sh
    kbelog -t "KB-E: ProgramTitle loaded" 
    # Clean things
    kbelog -t "KB-E Version: $VERSION"
    clear # Clear user UI for KB-E Summoning
    unset CLRS
    # DisplayTitle >:D
    kbelog -t "KB-E: Displaying title"; title 
    # Check KB-E dependencies
    kbelog -t "KB-E: Checking tools"; #checktools
    #if [ "$missing_dependencies" = "true" ]; then installtools; fi; checktools
    #if [ "$missing_dependencies" = "true" ]; then unset missing_dependencies; return 1; fi
    checksource # Check if theres a Kernel source to work with
    if [ "$available_kernel_source" = "false" ]; then return 1; fi
    # Initialize KB-E environment
    # Check for a stored device file specified by the user
    for c in $kbe_path/devices/*; do
      if [ "$2" = "$(basename $c)" ]; then
        DEVICE=$(basename $c)
        echo -e "   $THEME$BLD$DEVICE$WHITE device found...!$RATT"
        # Count directories in that device folder
        DNUMBER=$(find $kbe_path/devices/"$DEVICE"/* -maxdepth 0 -type d -print| wc -l)
        if [ "$DNUMBER" = "1" ]; then
          DATAFOLDER=$(basename $kbe_path/devices/$DEVICE/*)
          echo -e "$THEME$BLD   Info:$WHITE This device only contains one Kernel configured"
          echo -e "   $THEME$BLD$DATAFOLDER$WHITE found and sourced$RATT"
          # The name of the data folder is the "kernelname"
          # and inside that folder theres another "kernelname.data"
          device_kernel_path=$kbe_path/devices/$DEVICE/$DATAFOLDER/                 # Build Kernel Directory path
          device_kernel_file=$kbe_path/devices/$DEVICE/$DATAFOLDER/$DATAFOLDER.data # Build Kernel File path
        else
          echo -e "$THEME$BLD   Info:$WHITE This device has more than one Kernel configured"
          # If the user didn't specified the <kernelname> or is invalid, pick from list
          if [ -z "$3" ] || [ ! -d $kbe_path/devices/$DEVICE/$3 ]; then
            echo -e "   Please select one from the list"
            # Remember last path position
            CURF=$(pwd); cd $c
            # Make the list
            select kf in */; do test -n "$kf" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
            DATAFOLDER=$(basename $kf)
            # Head back
            cd $CURF; unset CURF
          # Else, if the <kernelname> provided by user exist, load it
          elif [ -d $kbe_path/devices/$DEVICE/$3 ]; then
            DATAFOLDER=$3
          fi
          echo -e "   $THEME$BLD$DATAFOLDER$WHITE sourced$RATT"
          device_kernel_path=$kbe_path/devices/$DEVICE/$DATAFOLDER                  # Build Kernel Directory Path
          device_kernel_file=$kbe_path/devices/$DEVICE/$DATAFOLDER/$DATAFOLDER.data # Build Kernel File path
        fi
        export device_kernel_path  # Export the path for the saved Kernel directory path
        export device_kernel_file  # Export the path for the saved Kernel file path
        source $device_kernel_file # Source the device settings to KB-E environment
        RD=1; NORS=1 # Mark KB-E as ready and don't run RS (runsettings.sh)
        # Clear some variables
        unset DATAFOLDER; unset DEVICE; unset DNUMBER; unset kf; unset c
      fi
    done
    if [ "$NORS" = "1" ]; then
      unset NORS # We don't need to run RS (runsettings.sh), neither this variable
    else
      source $kbe_path/resources/runsettings.sh # Configure a new device
      kbelog -t "LoadResources: Loading buildkernel script" 
    fi
    # Load KB-E script with Kernel building instructions
    source $kbe_path/resources/buildkernel.sh
    kbelog -t "LoadResources: Loading makedtb script" 
    # Load KB-E script with DTB Image building instructions
    source $kbe_path/resources/makedtb.sh; echo " "

    # --------------------
    # Done, KB-E is ready!
    # --------------------
    if [ "$RD" = "1" ]; then
     # Update kbe command completion
      updatecompletion
      echo -e "$THEME$BLD - Kernel-Building Essentials it's ready!$RATT"
      kbelog -t "KB-E is Ready for its use" 
      echo " "
    else
      # --------------------
      # Else, mission failed
      # --------------------
      if [ -f $kbe_path/devices/$KERNELNAME/$KERNELNAME.data ]; then
        rm $kbe_path/devices/$KERNELNAME/$KERNELNAME.data
      fi
      echo -e "$RED$BLD - KB-E couldn't initialize$RATT"
      kbelog -t "KB-E Session cancelled" 
      echo " "
      unset RD
    fi
    kbelog -f kbe 
  fi

  # ------------------------------
  # Update a saved device settings
  # ------------------------------
  if [ "$1" = "update" ]; then
    # Only run if KB-E is ready
    if [ -z "$kernel_name" ]; then
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
      kbelog -t "Building Kernel for $VARIANT (def: $DEFCONFIG)" 
      # Before start building, save the current folder path
      CURF=$(pwd)
      buildkernel
      # buildkernel process is done, head back to the previous path
      cd $CURF; unset CURF
      if [ "$BDTB" = "1" ]; then
        # User wants dtb
        kbelog -t "Building DTB for $VARIANT" 
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
        kbelog -t "Executing '$(grep MODULE_NAME ${!path} | cut -d '=' -f2)' Module..." 
        # Before executing a module, save the current path
        CURF=$(pwd)
        $EXEC
        # Head back to the saved path
        cd $CURF; unset CURF
      fi
    done
  done
}
