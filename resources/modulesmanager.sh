#!/bin/bash
# Module Manager
# By Artx <artx4dev@gmail.com>

# Module Manager main function
function mm_main() {
  # Module manager will be initialized from here
  # to do work for KB-E or the user depending on
  # how it is called or which args are provided

  # --setupdevice stands for KB-E device config
  # from runsetting.sh script, configure new
  # modules environment for it.
  if [ "$1" = "newconfig" ]; then
    # Config device
    kbelog -t "RunSettings: Entering modules selection" 
    echo -e "$WHITE  ------------------------------------"
    echo -e "$THEME$BLD             Module selection"
    echo -e "$WHITE  ------------------------------------"
    # Temporal Modules config file
    MLIST=$kbe_path/resources/other/modules.txt
    if [ -f $MLIST ]; then
      kbelog -t "RunSettings: Removing $MLIST file"; rm $MLIST
    fi
    kbelog -t "RunSettings: Creating $MLIST file"; touch $MLIST
    echo "# Modules Functions" > $MLIST
    k=1; x=1
    # For each module found...
    for i in $kbe_path/modules/*.sh; do
      # Check if it is a module
      unset module_name; module_name="$(grep MODULE_NAME $i | cut -d '=' -f2)"
      if [ ! -z "$module_name" ]; then
        echo " "
        echo -e "$WHITE  --------$THEME$BLD MODULE$WHITE --------"
        echo " "
        echo -e "$THEME$BLD   Name:$WHITE $(grep MODULE_NAME $i | cut -d '=' -f2)"
        echo -e "$THEME$BLD   kernel_version:$WHITE $(grep MODULE_VERSION $i | cut -d '=' -f2)"
        echo -e "$THEME$BLD   Description:$WHITE $(grep MODULE_DESCRIPTION $i | cut -d '=' -f2)"
        #echo -e "$THEME$BLD   Priority:$WHITE $(grep MODULE_PRIORITY $i | cut -d '=' -f2)"
        echo " "
        echo -e "$WHITE  ------------------------"
        echo " "
        echo -ne "$THEME$BLD   Enable:$WHITE $(grep MODULE_NAME $i | cut -d '=' -f2)? [Y/N]: "
        read  EM
        if [ "$EM" = y ] || [ "$EM" = Y ]; then
          kbelog -t "RunSettings: Module '$(grep MODULE_NAME $i | cut -d '=' -f2)' enabled" 
          echo "if [ -f $i ]; then" >> $MLIST
          echo "  export MODULE$((k++))=$(grep MODULE_FUNCTION_NAME $i | cut -d '=' -f2)" >> $MLIST
          echo "  export MPATH$((x++))=$i" >> $MLIST
          kbelog -t "RunSettings: Running '$(grep MODULE_NAME $i | cut -d '=' -f2)' module" 
          source $i
        # Save the path to execute the module, needed by device kernel_name file
          echo "  source $i" >> $MLIST
          echo "fi" >> $MLIST
        fi
      fi
    done
    kbelog -t "RunSettings: Exporting modules configuration"
    # Source modules file
    source $MLIST
    # Write modules info kernel config file
    # if at least one module is enabled
    if [ ! -z "$MODULE1" ]; then
      cat $MLIST >> $device_kernel_file
    fi
    # Remove temp Modules file
    rm $MLIST
    kbelog -t "RunSettings: Done"; return 1
  fi

  # --ui opens Module Manager options UI to manage
  # current device modules, this is from kbe.sh
  # when user runs command: kbe modules
  if [ "$1" = "--ui" ]; then
    # Open Module Manager options UI
    mm_ui
  fi
}

# Module Manager prompt UI
function mm_ui() {
  # Module Manager UI
  clear
  echo -e "  ------------------------------------"
  echo -e "             Module Manager           "
  echo -e "  ------------------------------------"
  echo " "
  echo -e "   Select an option: "
  echo " "
  echo -e "   1) Enable/Disable modules"
  echo -e "   2) Create a new module"
  echo -e "   3) Remove a module"
  echo -e "   4) Exit Module Manager"
  echo " "
  echo -e "  ------------------------------------"
  echo " "
  read -p "   Your option: " mm_option

  # Option 1, enable or disable modules
  if [ "$mm_option" = "1" ]; then
    mm_enable_disable
  fi

  # Option 2, create a new module
  if [ "$mm_option" = "2" ]; then
    mm_create
  fi

  # Option 3, remove a module
  if [ "$mm_option" = "3" ]; then
    mm_remove
  fi

  # Option 4, exit module manager
  if [ "$mm_option" = "4" ]; then
    return 1
  fi

  # If option is anything else
  if [ "$mm_option" = * ]; then
    mm_ui
  fi
}

# Enable or disable modules function
function mm_enable_disable() {
  :
}
