#!/bin/bash
# Core Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# KB-E Version and Revision
VERSION=1.0
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
  # Display Disclaimer
  disclaimer=$(cat resources/setup/disclaimer.txt); echo " "; echo $disclaimer; unset disclaimer
  echo " "; read -p " - Do you agree the above disclaimer and continue? [Y/N]: " DAG; echo " " 
  # Exit the pre-installation if user doesn't like it >:(
  if [ "$DAG" != "y" ] && [ "$DAG" != "Y" ]; then
    unset DAG; return 1
  fi
  read -p "   Thanks, good luck with your builds! Press enter to continue..."; echo " "
  # Initialize the pre-installation Script
  source resources/setup/preinstall.sh
  kbelog -t "KB-E: Pre-Installation is done"
  # Initialize the installation Script
  source resources/setup/install.sh
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
    # Here shows full usage information if KB-E is initialized
    if [ "$RD" = "1" ]; then
      echo " "
      echo -e "$THEME$BLD - Usage:$WHITE kbe start <device> <kernel>$THEME$BLD (Configure or load a device)$WHITE"
      echo -e "              clean $THEME$BLD(Wipes KB-E generated files, except devices)$WHITE"
      echo -e "              update <setting> <newvalue> $THEME$BLD(Update current device settings)$WHITE"
      echo -e "              upgrade $THEME$BLD(Upgrade KB-E to the latest version/changes)$WHITE"
      echo " "
      echo -e "              --kernel or -k $THEME$BLD(Builds the kernel)$WHITE"
      i=1
      while
        var=MODULE$((i++))
        [[ ${!var} ]]
      do
        path=MPATH$(($i - 1))
        [[ ${!path} ]]
        if [ -f ${!path} ]; then
          echo -e "              --${!var} $THEME$BLD($(grep MODULE_DESCRIPTION ${!path} | cut -d '=' -f2))$WHITE"
        fi
      done
      echo " "
      echo -e "   For more information use $THEME$BLD'kbhelp'$WHITE command$RATT"
      echo " "
    else
      # Here shows basic usage information if KB-E is not initialized
      echo " "
      echo " - Usage: kbe start <device> <kernel> (Configure or load a device)"
      echo "              clean (Wipes KB-E generated files, except devices)"
      echo "              root (teleport into KB-E root folder)"
      echo "              upgrade (Upgrade KB-E to the latest version/changes)"
      echo " "
    fi
  fi

  # ----------------------------------
  # Show status for the current device
  # ----------------------------------
  if [ "$1" = "status" ] && [ ! -z "$device_variant" ]; then
    echo " "
    echo -e "$THEME$BLD   -$WHITE Device$THEME$BLD  ----------------------------------------"; echo " "
    echo -e "$THEME$BLD   Currently working on device:$WHITE $device_variant"
    echo -e "$THEME$BLD   Kernel name:$WHITE $kernel_name"
    echo -e "$THEME$BLD   Target Android:$WHITE $target_android"
    echo -e "$THEME$BLD   Version:$WHITE $kernel_version"
    echo -e "$THEME$BLD   Release Type:$WHITE $release_type"; echo " "
    echo -e "$THEME$BLD   -$WHITE Kernel$THEME$BLD  ----------------------------------------"; echo " "
    echo -e "$THEME$BLD   Arch Type:$WHITE $kernel_arch"
    echo -e "$THEME$BLD   Kernel source:$WHITE $kernel_source"
    echo -e "$THEME$BLD   Defconfig:$WHITE $kernel_defconfig"
    echo -e "$THEME$BLD   Showing CC output:$WHITE $show_cc_out"; echo " "
    echo -e "$THEME$BLD   --------------------------------------------------"
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

  # ------------
  # CD into KB-E
  # ------------
  if [ "$1" = "root" ]; then
    # Get inside KB-E root
    cd $kbe_path
  fi

  # ---------------------
  # CD into Kernel Source
  # ---------------------
  if [ "$1" = "cdsource" ]; then
    if [ -z "$kernel_source" ]; then
      echo "KB-E: Start a device first"
    else
      cd $kernel_source
    fi
  fi

  # ----------
  # Clean KB-E
  # ----------
  if [ "$1" = "clean" ]; then
    # Logs
    if [ -d $kbe_path/logs ]; then
      rm $kbe_path/logs/*
    fi
    # First run indicator
    rm $kbe_path/resources/other/firstrun
    # Extracted ToolChains
    for dir in $kbe_path/resources/linaro/*; do
      if [ "$dir" != "downloads" ]; then
        rm -rf $dir
      fi
    done
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
        echo -e "$WHITE  ------------------------------------"
  	echo -e "$THEME$BLD              Device Found            "
  	echo -e "$WHITE  ------------------------------------"
        echo -e " "
        echo -e "$THEME$BLD   Name:$WHITE $DEVICE"
        # Count directories in that device folder
        DNUMBER=$(find $kbe_path/devices/"$DEVICE"/* -maxdepth 0 -type d -print| wc -l)
        if [ "$DNUMBER" = "1" ]; then
          DATAFOLDER=$(basename $kbe_path/devices/$DEVICE/*)
          echo -e "$THEME$BLD   Kernel: $WHITE$DATAFOLDER found and sourced$RATT"
          echo " "; echo -e "$WHITE  ------------------------------------"
          # The name of the data folder is the "kernelname"
          # and inside that folder theres another "kernelname.data"
          device_kernel_path=$kbe_path/devices/$DEVICE/$DATAFOLDER/                 # Build Kernel Directory path
          device_kernel_file=$kbe_path/devices/$DEVICE/$DATAFOLDER/$DATAFOLDER.data # Build Kernel File path
        else
          echo -e "$THEME$BLD   Info:$WHITE This device has more than"
          echo -e "         one Kernel configured"
          # If the user didn't specified the <kernelname> or is invalid, pick from list
          if [ -z "$3" ] || [ ! -d $kbe_path/devices/$DEVICE/$3 ]; then
            echo -e "$THEME$BLD   Info:$WHITE Please select one from the list"
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
          echo -e "$THEME$BLD   Kernel: $WHITE$DATAFOLDER found and sourced$RATT"
          echo " "; echo -e "$WHITE  ------------------------------------"
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
      echo "Settings: - targetandroid | Whatever"
      echo "          - version       | Numbers preferred"
      echo "          - releasetype   | stable | beta"
      echo "          - arch          | arm | arm64"
      echo "          - kernelsource  | Select from list"
      echo "          - defconfig     | Select from list if not specified"
      echo "          - showcc        | yes | no"
      echo " "
    else
      # If user specified a valid or invalid setting,
      # function "updatedevice" is now reponsible
      device_write $2 $3
    fi
  fi

  # ------------------------
  # Get number of threads if
  # it is specified
  # ------------------------
  unset n; unset build_threads
  # Set by default all available threads
  export build_threads=$(nproc)
  for n in $@; do
    [[ "$n" == "-j"* ]] &&
    export build_threads=$(echo $n | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
    if [ "$build_threads" = "" ]; then
      export build_threads=$(nproc)
    elif (( $build_threads > $(nproc) )); then echo " ";
      echo -e "$RED$BLD Warning:$WHITE Number of threads specified   $THEME$BLD($build_threads)"
      echo -e "$WHITE          is higher than existing ones  $RED$BLD($(nproc))$RATT"; echo " "
    fi
  done

  # -----------------------
  # Kernel, DTB and Modules
  # -----------------------
  # First of all, KB-E buildkernel and makedtb scripts, these
  # ones are top priority
  for g in $@; do
    if [ "$g" = "--kernel" ] || [ "$g" = "-k" ] && [ "$RD" = "1" ]; then
      # Get number of threads if it's specified
      for n in $@; do
        if [ "$n" = "-j"* ]; then
          build_threads=$(grep "-j" $n | cut -d 'j' -f2)
          echo $build_threads
          echo "detected"
        fi
      done
      # Setup post-build.d folder
      if [ ! -d $kbe_path/post-build.d ]; then
        setup_postbuild
      fi
      # User wants his kernel... If it builds...
      kbelog -t "Building Kernel for $VARIANT (def: $DEFCONFIG)" 
      # Before start building, save the current folder path
      CURF=$(pwd)
      buildkernel
      # buildkernel process is done, head back to the previous path
      cd $CURF; unset CURF
      if [ "$kernel_build_dtb" = "true" ]; then
        # User wants dtb
        kbelog -t "Building DTB for $VARIANT" 
        makedtb
      fi
      # Execute post-build.d scripts if kernel were built
      if [ "$kernel_build_failed" = "true" ]; then
        kbelog -t "KB-E: no post-build.d scripts to run"
      else
        execute_postbuild
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
      if [ -f ${!path} ]; then
        if [ "--$(grep MODULE_FUNCTION_NAME ${!path} | cut -d '=' -f2)" = "$a" ] && [ "$RD" = "1" ]; then
          EXEC=$(grep MODULE_FUNCTION_NAME ${!path} | cut -d '=' -f2)
          kbelog -t "Executing '$(grep MODULE_NAME ${!path} | cut -d '=' -f2)' Module..." 
          # Before executing a module, save the current path
          CURF=$(pwd)
          $EXEC
          # Head back to the saved path
          cd $CURF; unset CURF
        fi
      fi
    done
  done
}
