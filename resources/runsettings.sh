#!/bin/bash
# Session settings
# By Artx <artx4dev@gmail.com>

# Clear Variables (Just in case)
kbelog -t "RunSettings: Clearing variables" 
unset kernel_name; unset target_android; unset kernel_version; unset device_variant;
unset BLDTYPE; unset kernel_source; unset; unset clear_source_onbuild; unset ARMT; unset kernel_arch
unset kernel_build_dtb; unset release_type; unset AKBO; unset show_cc_out; unset RD; unset release_type;

#--------------------------------------
# Script Functions
#--------------------------------------

# Save data
function storedata () {
  case $1 in
    "-t") echo "$2" >> $kbe_path/devices/$device_variant/$kernel_name/$kernel_name.data ;;
    "-v") echo "export $2=$3" >> $kbe_path/devices/$device_variant/$kernel_name/$kernel_name.data ;;
    "-n") echo "# Configuration file for $kernel_name" > $kbe_path/devices/$device_variant/$kernel_name/$kernel_name.data ;;
    "-d") if [ ! -d $kbe_path/devices/$device_variant ]; then
            mkdir $kbe_path/devices/$device_variant
          fi
          if [ ! -d $kbe_path/devices/$device_variant/$kernel_name ]; then
            mkdir $kbe_path/devices/$device_variant/$kernel_name;
          fi;
          if [ ! -f $kbe_path/devices/$device_variant/$kernel_name/$kernel_name.data ]; then
            touch $kbe_path/devices/$device_variant/$kernel_name/$kernel_name.data;
          fi ;;
  esac
}

# -----------------
# Basic information
# -----------------
function getusrbasics() {
  unset ERR
  echo -e "$WHITE  ------------------------------------"
  echo -e "$THEME$BLD              Setup Basics             "
  echo -e "$WHITE  ------------------------------------"
  echo " "
  echo -ne "   Kernel Name$THEME$BLD:$WHITE "; read kernel_name; export kernel_name
  if [ "$kernel_name" = "" ]; then ERR=1; return 1; fi; kbelog -t "RunSettings: Kernel name: $kernel_name"
  echo -ne "   Target Android OS$THEME$BLD:$WHITE "; read target_android; export target_android
  if [ "$target_android" = "" ]; then ERR=1; return 1; fi; kbelog -t "RunSettings: Target OS: $target_android"
  echo -ne "   Version$THEME$BLD:$WHITE "; read kernel_version; export kernel_version
  if [ "$kernel_version" = "" ]; then ERR=1; return 1; fi; kbelog -t "RunSettings: kernel_version: $kernel_version" 
};

# -------------
# Kernel Config
# -------------
function getkconfig() {
  unset ERR
  echo -e "$WHITE  ------------------------------------"
  echo -e "$THEME$BLD              Kernel Source         "
  echo -e "$WHITE  ------------------------------------"
  echo " "
  echo -e "   Kernel source(s) available$THEME$BLD:";
  k=1
  for i in $kbe_path/source/*/; do
    echo -e "$THEME$BLD   $((k++)))$WHITE $(basename $i)"
    export "kfolder$((k-1))=$i";
  done
  unset nro; unset source_folder; echo " "
  while [ "$source_folder" = "" ]; do
    read -p "   Select: " nro
    if [ "$nro" -eq "0" ]; then
      echo -e "$RED$BLD   Plase enter a valid number$WHITE"
    elif [ "$nro" = "" ] || [ "$nro" -gt "$k" ]; then
      echo -e "$RED$BLD   Please enter a valid number$WHITE"
    else
      source_folder=kfolder$nro
      export kernel_source=${!source_folder}
      break
    fi
  done
  kbelog -t "RunSettings: Exported kernel source to $kernel_source" 
  echo " "
  echo -e "$WHITE  ------------------------------------"
  echo -e "$THEME$BLD          Kernel Configuration         "
  echo -e "$WHITE  ------------------------------------"
  echo " "
  # Get the CPU Architecture
  echo -e "$THEME$BLD   CPU Architecture ($WHITE Option 1 = 32Bits"
  echo -e "   devices and Option 2 =  64Bits devices $THEME$BLD) $WHITE"
  until [ "$ARMT" = "1" ] || [ "$ARMT" = "2" ]; do
    echo -ne "   Your option$THEME$BLD [1/2]:$WHITE "; read ARMT
    if [ "$ARMT" != "1" ] && [ "$ARMT" != "2" ]; then
      echo -e "$RED$BLD   Error, invalid option, try again...$WHITE"
    fi
  done
  if [ "$kernel_arch" = "arm64" ] && [ ! -d $kernel_source/arch/$kernel_arch/ ]; then
    echo " "
    echo -e "$RED$BLD   This Kernel Source doesn't contains 64bits defconfigs... Exiting...$RATT"
    echo " "; kbelog -t "RunSettings: This kernel source doesnt contains 64bits defconfig, exiting KB-E..." 
    export CWK=n; ERR=1; return 1
  fi
  if [ "$kernel_arch" = "arm" ] && [ ! -d $kernel_source/arch/$kernel_arch/ ]; then
    echo " "
    echo -e "$RED$BLD   This Kernel Source doesn't contains 32bits defconfigs... Exiting...$RATT"
    echo " "; kbelog -t "RunSettings: This kernel source doesnt contains 32bits defconfig, exiting KB-E..." 
    export CWK=n; ERR=1; return 1
  fi
  case $ARMT in
       "1") export kernel_arch=arm; kbelog -t "RunSettings: kernel_arch=arm" ;;
       "2") export kernel_arch=arm64; kbelog -t "RunSettings: kernel_arch=arm64" ;;
  esac

  # Variant and Defconfig
  until [ "$device_variant" != "" ]; do
    echo -ne "   Device Variant $THEME$BLD($WHITE e.g., 'bacon'$THEME$BLD ):$WHITE "
    read device_variant; export device_variant; kbelog -t "RunSettings: Variant: $device_variant defined" 
    if [ "$device_variant" = "" ]; then
      echo -e "$RED$BLD   Please write device variant (Device codename or device name)$WHITE"
    fi
  done
  echo -e "   Select a Defconfig $THEME$BLD($WHITE e.g., 'bacon_defconfig'$THEME$BLD ):$WHITE "
  echo " "
  k=1
  for i in $kernel_source/arch/$kernel_arch/configs/*; do
    echo -e "$THEME$BLD   $((k++)))$WHITE $(basename $i)"
    export "DEFCONFIG$((k-1))=$(basename $i)";
  done
  unset nro; unset DEF; echo " "
  while [ "$DEF" = "" ]; do
    read -p "   Select: " nro
    if [ "$nro" -eq "0" ]; then
      echo -e "$RED$BLD   Plase enter a valid number$WHITE"
    elif [ "$nro" = "" ] || [ "$nro" -gt "$k" ]; then
      echo -e "$RED$BLD   Please enter a valid number$WHITE"
    else
      DEF=DEFCONFIG$nro
      export kernel_defconfig=${!DEF}
      break
    fi
  done
  kbelog -t "RunSettings: Defconfig: $kernel_defconfig" 
};

# -------------------
# Setup CrossCompiler
# -------------------
function getcc() {
  unset ERR
  echo -e "$WHITE  ------------------------------------"
  echo -e "$THEME$BLD             CrossCompiler           "
  echo -e "$WHITE  ------------------------------------"
  echo " "
  echo -e "   Select a CrossCompiler:"
  echo -e " "
  echo -e "$THEME$BLD     1)$WHITE Google GCC $THEME$BLD(default)"
  echo -e "$THEME$BLD     2)$WHITE Linaro ToolChain"
  echo -e "$THEME$BLD     3)$WHITE UberTC"
  echo -e "$THEME$BLD     4)$WHITE Set Custom"
  echo -e " "
  # CrossCompiler options available
  AOPTS=4
  re='^[0-9]+$'
  # Load CrossCompilers manager script
  source $kbe_path/resources/cc.sh
  # Use has to select a valid option
  while true; do
    read -e -p "   Select: " -i "1" cc_selected
    if ! [[ $cc_selected =~ $re ]]; then
      echo -e "$RED$BLD   Incorrect input, try a gain$WHITE"
    elif [ "$cc_selected" -eq "0" ]; then
      echo -e "$RED$BLD   Incorrect input, try again$WHITE"
    else
      if [ "$cc_selected" -gt "$AOPTS" ]; then
        echo -e "$RED$BLD   Error:$WHITE theres only 3 valid options, try again"
      else
        break
      fi
    fi
  done

  # Option 1: Google GCC
  if [ "$cc_selected" = "1" ]; then
    cc_setup_gcc
    if [ "$kernel_arch" = "arm" ]; then
      export kernel_cc=$gcc_path32
    fi
    if [ "$kernel_arch" = "arm64" ]; then
      export kernel_cc=$gcc_path64
      export CROSS_COMPILE_ARM32=$gcc_path32
    fi
    if [ -z "$kernel_cc" ]; then
      echo -e "$RED$BLD   Error:$WHITE there was an issue setting up Google GCC$RATT"
      ERR=1
    fi
  fi

  # Option 2: Linaro
  if [ "$cc_selected" = "2" ]; then
    cc_setup_linaro
    if [ "$kernel_arch" = "arm" ]; then
      export kernel_cc=$linaro_path32
    fi
    if [ "$kernel_arch" = "arm64" ]; then
      export kernel_cc=$linaro_path32
      export CROSS_COMPILE_ARM32=$linaro_path64
    fi
  fi

  # Option 4: Custom CC
  if [ "$cc_selected" = "4" ]; then
    cc_setup_custom
    if [ -z "$custom_path" ]; then
      echo -e "$RED$BLD   Error:$WHITE there was an issue setting up your Custom CC"
      ERR=1
    else
      export kernel_cc=$custom_path
    fi
  fi
};

# ------------------------
# Other misc configuration
# ------------------------
function otherkconfig() {
  unset ERR
  echo -e "$WHITE  ------------------------------------"
  echo -e "$THEME$BLD              Other Config           "
  echo -e "$WHITE  ------------------------------------"
  echo " "

  # Ask the user if he wants to release stable or beta builds
  echo -e "   Release Type $THEME$BLD("$WHITE"1 = Stable; 2 = Beta$THEME$BLD)$WHITE";
  read -e -p "   Select: " -i "1" release_type
  if [ "$release_type" -eq "1" ] || [ "$release_type" -eq "2" ]; then
    :
  else
    ERR=1; return 1
  fi
  if [ "$release_type" = "1" ]; then release_type="Stable"; elif [ "$release_type" = "2" ]; then release_type="Beta"; fi; export release_type
  kbelog -t "Runsettings: Release Type: $release_type"

  # Ask the user if he wants the original CrossCompiler output 
  # or KB-E simplified output while building the kernel
  read -e -p "   Show original CC output? [y/n]: " -i "y" CCSHOW
  if [ $CCSHOW = y ] || [ $CCSHOW = Y ]; then
    export show_cc_out=true; kbelog -t "RunSettings: Showing original CrossCompiler output" 
  fi

  # Ask the user if he wants to build DTB automatically
  read -e -p "   Build DTB automatically? [y/n]: " -i "y" BDTB
  if [ "$BDTB" = "y" ] || [ "$BDTB" = "Y" ]; then
    kbelog -t "RunSettings: Building DTB Manually" 
    export kernel_build_dtb=true
  else
    export kernel_build_dtb=false
  fi

  # Ask the user if he wants to clear the kernel source each build
  read -e -p "   Clear Source each build? [y/n]: " -i "n" CLRS
  if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
    kbelog -t "RunSettings: Cleaning source on every build" 
    export clear_source_onbuild=true
  fi
};

# Let's initialize a new device calling the above functions
getusrbasics; if [ "$ERR" = "1" ]; then export ERR="Couldn't get Basic info"; return 1; fi; echo " "
getkconfig; if [ "$ERR" = "1" ]; then export ERR="Couldn't get Kernel config"; return 1; fi; echo " "
getcc; if [ "$ERR" = "1" ]; then export ERR="Couldn't get CC config"; return 1; fi; echo " "
otherkconfig; if [ "$ERR" = "1" ]; then export ERR="User failed to provide a valid input"; return 1; fi; echo " "

# After all its done, store all the data collected
storedata -d; storedata -n
storedata -t "# User Data"
storedata -v kernel_name $kernel_name
storedata -v target_android $target_android
storedata -v kernel_version $kernel_version
storedata -v release_type $release_type
storedata -t "# Arch Type"
storedata -v kernel_arch $kernel_arch
storedata -t "# CrossCompiler"
storedata -v kernel_cc $kernel_cc
if [ "$kernel_arch" = "arm64" ]; then
  storedata -v CROSS_COMPILE_ARM32 $CROSS_COMPILE_ARM32
fi
storedata -t "# Kernel Config"
storedata -v kernel_source $kernel_source
if [ "$show_cc_out" = "true" ]; then
  storedata -v show_cc_out $show_cc_out
fi
storedata -t "# Variant and Defconfig"
storedata -v device_variant $device_variant
storedata -v kernel_defconfig $kernel_defconfig
if [ "$clear_source_onbuild" = "true" ]; then
  storedata -v clear_source_onbuild $clear_source_onbuild
fi
storedata -v kernel_build_dtb $kernel_build_dtb
export device_kernel_path=$kbe_path/devices/$device_variant/$kernel_name/                 # Build Kernel Directory path
export device_kernel_file=$kbe_path/devices/$device_variant/$kernel_name/$kernel_name.data # Build Kernel File path

# Initialize new modules config on Module Manager
mm_main newconfig

# Create an out folder for this device kernel_name folder
if [ ! -d $device_kernel_path/out ]; then
  mkdir $device_kernel_path/out
fi

# Config process done
export RD=1
echo " "; kbelog -t "RunSettings: Config done, displaying 'kbe' command usage to user" 
echo -e "$WHITE  --------$THEME$BLD CONFIG DONE$WHITE --------"
echo " "
echo -e "$THEME$BLD - Usage:$WHITE kbe --kernel or -k $THEME$BLD(Builds the kernel)$WHITE"
echo -e "              --dtb or -dt $THEME$BLD(Builds device tree image)$WHITE"
i=1
while var=MODULE$((i++)); [[ ${!var} ]]; do
  path=MPATH$(($i-1)); [[ ${!path} ]];
  echo -e "              --${!var} $THEME$BLD($(grep MODULE_DESCRIPTION ${!path} | cut -d '=' -f2))$WHITE"
done
echo " "
echo -e "              --all $THEME$BLD(Does everything mentioned above)      $WHITE  | Work alone "
echo " "
echo -e "   For more information use $THEME$BLD'kbhelp'$WHITE command"
echo " "
echo -e "$WHITE  ---------------------------------------$THEME$BLD"
echo " "
read -p "   Press enter to continue..."
kbelog -t "RunSettings: All done" 
echo -ne "$WHITE"
