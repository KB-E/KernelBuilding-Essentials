#!/bin/bash
# KB-E Sub-Commands script
# By Artx <artx4dev@gmail.com>

# -----------------------------
# Use 'for' to support multiple
# sub-commands at once
# -----------------------------
for args in $@; do 
  # -------------------------------
  # To write your sub-command here
  # use an if that checks if the
  # provided "$args" is equal to
  # your argument name and write
  # your code inside that if
  # -------------------------------

  # ----------
  # Clean KB-E
  # ----------
  if [ "$args" = "clean" ]; then
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

  # ----------------------------------
  # Show status for the current device
  # ----------------------------------
  if [ "$args" = "status" ] && [ ! -z "$device_variant" ]; then
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
  if [ "$args" = "upgrade" ]; then
    if [ -f kbe.sh ]; then
      # git pull KB-E repo
      echo " "; echo "KB-E: Getting latest changes from repository"; echo " "
      git pull https://github.com/KB-E/KernelBuilding-Essentials; echo " "
      echo -n "KB-E: Loading log.sh script...    "; source resources/log.sh; echo " [ Done ]"
      echo -n "      Loading Updater Script...   "; source resources/updates.sh; echo " [ Done ]"
      echo -n "      Loading programtool.sh...   "; source resources/programtools.sh; echo " [ Done ]"
      echo -n "      Generating new init file... "; kbePatch; echo " [ Done ]"
      echo -n "      Checking ~/.bashrc...       "; bashrcPatch --silent; echo " [ Done ]"
      echo -n "      Reloading ~/.bashrc...      "; source ~/.bashrc; echo " [ Done ]"
      echo -n "      Checking Dependencies...    "; checktools; echo " [ Done ]"
      echo " "
    else
      echo " "; echo "KB-E: Error, you must run this command inside kb-e folder"
      echo "KB-E: run 'kbe root' and try again"; echo " "
    fi
  fi

  # ---------------------
  # CD into Kernel Source
  # ---------------------
  if [ "$args" = "cdsource" ]; then
    if [ -z "$kernel_source" ]; then
      echo "KB-E: Start a device first"
    else
      cd $kernel_source
    fi
  fi

  # -----------------
  # CD into KB-E root
  # -----------------
  if [ "$args" = "root" ]; then
    cd $kbe_path
  fi

done
