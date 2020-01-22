#!/bin/bash

# Program tools functions
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Install Building Tools
function installtools() {
  kbelog -t "Installing dependencies..."
  echo " "
  sudo apt-get update
  sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev device-tree-compiler ccache libc++-dev gcc
  echo " "
  kbelog -t "Dependencies installed"
}
export -f installtools; kbelog -f installtools

function checktools() {
  kbelog -t "CheckTools: Checking dependencies..."
  declare -a progtools=("git" "build-essential" "kernel-package" "fakeroot" "libncurses5-dev" "libssl-dev" "device-tree-compiler" "ccache" "libc++-dev")
  for i in "${progtools[@]}"
  do
    PROGRAMINST=$(dpkg -s "$i" | grep Status | cut -d ":" -f 2)
    if [ "$kernel_sourceROGRAMINST" != " install ok installed" ]; then
      echo -e "$RED$BLD   $i is Missing"; kbelog -t "CheckTools: $i is missing"
      export missing_dependencies=true
      break
    fi
  done
}
export -f checktools; kbelog -f checktools

# Check if theres a kernel source
function checksource() {
  unset available_kernel_source
  for folder in $kbe_path/source/*; do
    if [ -f $folder/Makefile ]; then
      kbelog -t "RunSettings: Kernel source foudn"
      break
    else
      kbelog -t "RunSettings: Warning, no kernel source found"
      export available_kernel_source=false
      echo " "; break
    fi
  done
}
export -f checksource; kbelog -f checksource

# Check CrossCompiler
function checkcc() {
  kbelog -t "CheckCC: Checking CrossCompiler..."
  # CrossCompiler checker
  if [ ! -f "$kernel_cc"gcc ]; then
    echo -e "$RED$BLD   Cross Compiler not found ($kernel_cc) "; kbelog -t "CheckCC: CrossCompiler not found"
    export cc_available=false # Export CC not ready
  else
    echo -e "$WHITE   Cross Compiler Found!"; kbelog -t "CheckCC: CrossCompiler found"
    export cc_available=true  # Export CC is ready
  fi
}
export -f checkcc; kbelog -f checkcc

# Check DTB Tool
function checkdtbtool() {
  kbelog -t "CheckDTBTool: Checking DTB Tool..."
  echo " "
  if [ ! -f $kbe_path/resources/dtbtool/dtbtool.c ]; then # Check local dtbTool
  echo -e "$RED$BLD   DTB Tool source not found$RATT$WHITE"; kbelog -t "CheckDTBTool: DTB Tool source not found"
  echo -ne "$WHITE   Downloading from Github..."; kbelog -t "CheckDTBTool: Downloading from Github..."
  git clone https://github.com/KB-E/dtbtool resources/dtbtool &> /dev/null
  echo -e "$THEME$BLD Done$RATT"; kbelog -t "CheckDTBTool: Done"
else
  # If you didn't removed it, dtb is fine
  echo -e "$WHITE   DTB Tool source found"; kbelog -t "CheckDTBTool: DTB Tool source found"
fi
}
export -f checkdtbtool; kbelog -f checkdtbtool

function device_read() {
  # Read and export the desired value from the device_kernel_file
  case $1 in
    "targetandroid") export target_android=$(grep target_android $device_kernel_file | cut -d '=' -f2) ;;
          "version") export kernel_version=$(grep kernel_version $device_kernel_file | cut -d '=' -f2) ;;
      "releasetype") export release_type=$(grep release_type $device_kernel_file | cut -d '=' -f2) ;;
             "arch") export kernel_arch=$(grep kernel_arch $device_kernel_file | cut -d '=' -f2) ;;
     "crosscompile") export kernel_cc=$(grep kernel_cc $device_kernel_file | cut -d '=' -f2) ;;
     "kernelsource") export kernel_source=$(grep kernel_source $device_kernel_file | cut -d '=' -f2) ;;
           "showcc") export show_cc_out=$(grep show_cc_out $device_kernel_file | cut -d '=' -f2) ;;
          "variant") export device_variant=$(grep device_variant $device_kernel_file | cut -d '=' -f2) ;;
        "defconfig") export kernel_defconfig=$(grep kernel_defconfig $device_kernel_file | cut -d '=' -f2) ;;
  esac
}
function device_write() {
  # Check if the user supplied a available setting and process it
  case $1 in
                     # Update targetandroid in devicefile
    "targetandroid") if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for targetandroid"; return 1; fi
                     device_read targetandroid;
                     sed -i "s/export target_android=$target_android/export target_android=$2/g" $device_kernel_file;
                     export target_android=$2;
                     echo "KB-E: Update: targetandroid updated to '$2'"; return 1 ;;
                     # Update version in devicefile

          "version") if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for version"; return 1; fi
                     device_read version;
                     sed -i "s/export kernel_version=$kernel_version/export kernel_version=$2/g" $device_kernel_file;
                     export kernel_version=$2;
                     echo "KB-E: Update: version updated to '$2'"; return 1 ;;

      "releasetype") # Update the release type
                     if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for releasetype"; return 1; fi
                     if [ "$2" = "stable" ] || [ "$2" = "beta" ]; then
                       device_read releasetype
                       sed -i "s/export release_type=$release_type/export release_type=$2/g" $device_kernel_file;
                       export release_type=$2;
                       echo "KB-E: Update: releasetype updated to '$2'"; return 1;
                     else
                       echo "KB-E: Update: error, releasetype only accept 'Stable' or 'Beta' values";
                       return 1;
                     fi ;;

           "showcc") # Update the Kernel debugging toggle
                    if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for kdebug"; return 1; fi
                     if [ "$2" = "yes" ]; then
                       device_read showcc
                       if [ "$show_cc_out" = "true" ]; then
                         echo "KB-E: Update: kdebug is already enabled"; return 1
                       else
                         sed -i "s/export show_cc_out=false/export show_cc_out=true/g" $device_kernel_file
                         export show_cc_out=true
                         echo "KB-E: Update: kdebug is now enabled"; return 1
                       fi
                     fi
                     if [ "$2" = "no" ]; then
                       device_read showcc
                       if [ "$show_cc_out" = "false" ]; then
                         echo "KB-E: Update: kdebug is already disabled"; return 1
                       else
                         sed -i "s/export show_cc_out=true/export show_cc_out=false/g" $device_kernel_file
                         export show_cc_out=false
                         echo "KB-E: Update: kdebug is now disabled"; return 1
                       fi
                     fi ;;

     "kernelsource") # Update the Kernel source
                     cd $kbe_path/source; device_read arch; device_read kernelsource;
                     echo " "; echo -e "$WHITE   Select a$THEME$BLD Kernel Source:$WHITE"
  		               select NEWPATH in */; do test -n "$NEWPATH" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
		                 cd $kbe_path; sed -i "s+export kernel_source=$kernel_source+export kernel_source=$kbe_path/source/$NEWPATH+g" $device_kernel_file
  		               device_read kernelsource; echo " "; echo -e "$THEME$BLD   Done$RATT"; echo " "; return 1 ;;

             "arch") # Update the arch type (this also includes the crosscompiler automatically)
                     if [ -z "$2" ]; then echo "KB-E: Update: error, no newvalue for arch"; return 1; fi
                     if [ "$2" = "arm" ] || [ "$2" = "arm64" ]; then
                       device_read arch
                       device_read kpath
                       if [ "$2" = "arm" ] && [ ! -d $kernel_source/arch/$kernel_arch ]; then
                         echo "KB-E: Update: error, you are trying to switch to 'arm' but your source doesnt support it";
                         return 1
                       elif [ "$2" = "arm64" ] && [ ! -d $kernel_source/arch/$kernel_arch ]; then
                         echo "KB-E: Update: error, you are trying to switch to 'arm64' but your source doesnt support it";
                         return 1
                       fi
                       sed -i "s/export kernel_arch=$kernel_arch/export kernel_arch=$2/" $device_kernel_file;
                       export kernel_arch=$2;
                       echo "KB-E: Update: arch type updated to '$2'";
                       if [ "$2" = "arm" ]; then
                         device_read crosscompile;
                         sed -i "s+export kernel_cc=$kernel_cc+export kernel_cc=$kbe_path/resources/crosscompiler/arm/bin/arm-linux-androideabi-+g" $device_kernel_file;
                         echo "KB-E: Update: crosscompile updated to arm to match arch type";
                         export kernel_cc=$kbe_path/resources/crosscompiler/arm/bin/arm-linux-androideabi-
                       elif [ "$2" = "arm64" ]; then
                         device_read crosscompile;
                         sed -i "s+export kernel_cc=$kernel_cc+export kernel_cc=$kbe_path/resources/crosscompiler/arm64/bin/aarch64-linux-android-+g" $device_kernel_file;
                         echo "KB-E: Update: crosscompile updated to arm64 to match arch type";
                         export kernel_cc=$kbe_path/resources/crosscompiler/arm64/bin/aarch64-linux-android-
                       fi
                       return 1;
                     else
                       echo "KB-E: Update: error, arch type only accept 'arm' or 'arm64' values";
                       return 1;
                     fi ;;

        "defconfig") # Update the defconfig file
                     CURF=$(pwd)
                     device_read arch; device_read defconfig; #device_read kpath;
                     if [ -z "$2" ]; then
                       echo "KB-E: Update: Select a defconfig:";
                       cd $kernel_source/arch/$kernel_arch/configs/;
                       select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
                       sed -i "s/export kernel_defconfig=$kernel_defconfig/export kernel_defconfig=$DEF/g" $device_kernel_file;
                       export kernel_defconfig=$DEF; unset DEF;
                       cd $CURF; unset CURF; echo "KB-E: Update: defconfig updated to '$kernel_defconfig'";
                       return 1;
                     fi
                     if [ -f $kernel_source/arch/$kernel_arch/configs/"$2" ]; then
                       sed -i "s/export kernel_defconfig=$kernel_defconfig/export kernel_defconfig=$2/g" $device_kernel_file;
                       export kernel_defconfig=$2;
                       echo "KB-E: Update: defconfig updated to '$2'"; return 1;
                     else
                       echo "KB-E: Update: supplied defconfig file name doesn't exist in kernel source";
                       return 1;
                     fi ;;

  esac

  # Anything else is not supported
  if [ ! -z "$1" ]; then
    echo "KB-E: Update: supplied setting '$1' is not supported"
    return 1
  fi
}
export -f device_write; kbelog -f device_write

function bashrcPatch() {
  # Patch ~/.bashrc to load KB-E init file
  if grep -q "# Load KB-E init file" ~/.bashrc; then
    if [ "$1" != "--silent" ]; then
      echo " "; echo -e "$THEME$BLD - ~/.bashrc is already patched..!$RATT"
    fi
  else
    kbelog -t "Install: Patching ~/.bashrc"; echo " "
    echo -ne "$THEME$BLD - Patching ~/.bashrc to load init file...$WHITE"
    echo "# Load KB-E init file" >> ~/.bashrc
    echo "source $kbe_path/resources/init/init.sh" >> ~/.bashrc
    echo -e " Done$RATT"
  fi
}
export -f bashrcPatch; kbelog -f bashrcPatch

function kbePatch() {
  # Create a init file for KB-E
  INITPATH=$kbe_path/resources/init/init.sh
  if [ ! -f $INITPATH ]; then
    touch $INITPATH
  fi
  echo "#!/bin/bash" > $INITPATH
  echo "" >> $INITPATH
  echo "# KB-E init script" >> $INITPATH
  echo "# This is automatically generated, do not edit" >> $INITPATH
  echo "" >> $INITPATH
  echo "# Load KB-E Function and Path" >> $INITPATH
  echo "kbe_path=$kbe_path" >> $INITPATH
  echo "source $kbe_path/resources/other/colors.sh" >> $INITPATH
  echo "source $kbe_path/resources/log.sh" >> $INITPATH
  echo "source $kbe_path/kbe.sh --init" >> $INITPATH
  echo "complete -W 'start upgrade' kbe" >> $INITPATH
  echo "" >> $INITPATH
  echo "# Load configurable init script" >> $INITPATH
  echo "if [ -f $kbe_path/resources/init/kbeinit.sh ]; then" >> $INITPATH
  echo "  source $kbe_path/resources/init/kbeinit.sh" >> $INITPATH
  echo "fi" >> $INITPATH
}
export -f kbePatch; kbelog -f kbePatch

function updatecompletion() {
  # Update the completion for kbe command
  # Get all active modules
  X=1; module=MODULE$X
  unset moduleargs
  while :; do
    if [ -z "${!module}" ]; then
      break
    else
      moduleargs="$moduleargs --${!module}"
      ((X++))
      module=MODULE$X
    fi
  done
  complete -W "start clean update upgrade status help --kernel --dtb theme root cdsource $moduleargs" kbe
}
export -f updatecompletion; kbelog -f updatecompletion

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
  echo " "
  echo -e "$WHITE  ------------------------------------"
  echo -e "$THEME$BLD           Kernel Configuration         "
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
  case $ARMT in
       "1") export kernel_arch=arm; kbelog -t "RunSettings: kernel_arch=arm" ;;
       "2") export kernel_arch=arm64; kbelog -t "RunSettings: kernel_arch=arm64" ;;
  esac
  # Variant
  until [ "$device_variant" != "" ]; do
    echo -ne "   Device Variant $THEME$BLD($WHITE e.g., 'bacon'$THEME$BLD ):$WHITE "
    read device_variant; export device_variant; kbelog -t "RunSettings: Variant: $device_variant defined" 
    if [ "$device_variant" = "" ]; then
      echo -e "$RED$BLD   Please write device variant (Device codename or device name)$WHITE"
    fi
  done
};
export -f getusrbasics; kbelog -f getusrbasics

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
  # Defconfig
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
export -f getkconfig; kbelog -f getkconfig

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
export -f getcc; kbelog -f getcc

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
export -f otherkconfig; kbelog -f otherkconfig