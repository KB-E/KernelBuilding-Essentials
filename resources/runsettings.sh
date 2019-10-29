#!/bin/bash
# Session settings
# By Artx <artx4dev@gmail.com>

# Clear Variables (Just in case)
kbelog -t "RunSettings: Clearing variables" 
unset kernel_name; unset target_android; unset kernel_version; unset device_variant;
unset BLDTYPE; unset kernel_source; unset; unset clear_source_onbuild; unset ARMT; unset kernel_arch
unset kernel_build_dtb; unset release_type; unset AKBO; unset show_cc_out; unset RD; unset release_type;

# checksource # Check if theres a Kernel source to work with
if [ "$CWK" = "n" ]; then return 1; fi

#-------------------------
# Script Functions
#-------------------------

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

# Essencial Data
function promptdata() {
  unset ERR
  # Prompt for data
  echo -e "$WHITE -------------------------"
  echo -e "$THEME$BLD - Setup Basics:"
  echo -e "$WHITE -------------------------"
  echo " "
  echo -ne "   Kernel Name$THEME$BLD:$WHITE "; read kernel_name; export kernel_name
  if [ "$kernel_name" = "" ]; then ERR=1; return 1; fi; kbelog -t "RunSettings: Kernel name: $kernel_name"
  echo -ne "   Target Android OS$THEME$BLD:$WHITE "; read target_android; export target_android
  if [ "$target_android" = "" ]; then ERR=1; return 1; fi; kbelog -t "RunSettings: Target OS: $target_android"
  echo -ne "   Version$THEME$BLD:$WHITE "; read kernel_version; export kernel_version
  if [ "$kernel_version" = "" ]; then ERR=1; return 1; fi; kbelog -t "RunSettings: kernel_version: $kernel_version"
  echo -ne "   Release Type $THEME$BLD($WHITE 1 = Stable; 2 = Beta $THEME$BLD)$WHITE: "; read release_type; if [ "$release_type" = "" ]; then ERR=1; return 1; fi
  if [ "$release_type" = "1" ]; then release_type="Stable"; elif [ "$release_type" = "2" ]; then release_type="Beta"; fi; export release_type
  kbelog -t "Runsettings: Release Type: $release_type" 
};

# Arch selection
function getarch() {
  # Get the ARCH Type
  echo -e "$WHITE -------------------------"
  echo -e "$THEME$BLD - Arch Type Selection:"
  echo -e "$WHITE -------------------------"
  echo " "
  echo -e "$THEME$BLD   Select your CPU Architecture ($WHITE Option 1 = 32Bits"
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
};

# Download CC Based on Arch
function getcc() {
  # Define arm & arm64 CC paths
  CC=$kbe_path/resources/crosscompiler/arm/bin/arm-linux-androideabi-
  CC64=$kbe_path/resources/crosscompiler/arm64/bin/aarch64-linux-android-
  # Export the correspondent CrossCompiler for the ARCH Type
  case $kernel_arch in
       "arm") 
              kbelog -t "RunSettings: CC = $CC" ;
              # Check for arm CC
              if [ ! -f "$CC"gcc ]; then
                kbelog -t "RunSettings: arm CC not found, downloading...";
                echo -ne "$WHITE   Downloading the$THEME$BLD arm$WHITE CrossCompiler$THEME$BLD...";
                git clone https://github.com/KB-E/arm-linux-androideabi-4.9 $kbe_path/resources/crosscompiler/arm/ &> /dev/null;
                echo -e "$WHITE Done"; kbelog -t "RunSettings: Done"; echo " ";
              fi;
              export kernel_cc=$CC ;;
              
     "arm64") kbelog -t "RunSettings: CC = $cc64" ;
              # Check for arm64 CC
              if [ ! -f "$CC64"gcc ]; then
                kbelog -t "RunSettings: arm64 CC not found, downloading...";
                echo -ne "$WHITE   Downloading the$THEME$BLD arm64$WHITE CrossCompiler$THEME$BLD...";
                git clone https://github.com/KB-E/aarch64-linux-android-4.9 $kbe_path/resources/crosscompiler/arm64/ &> /dev/null;
                echo -e "$WHITE Done"; kbelog -t "RunSettings: Done"; echo " ";
              fi;
              # Check for arm CC (Needed by some arm64 kernels)
              if [ ! -f "$CC"gcc ]; then
                kbelog -t "RunSettings: arm CC not found, downloading...";
                echo -ne "$WHITE   Downloading the$THEME$BLD arm$WHITE CrossCompiler$THEME$BLD...";
                git clone https://github.com/KB-E/arm-linux-androideabi-4.9 $kbe_path/resources/crosscompiler/arm/ &> /dev/null;
                echo -e "$WHITE Done"; kbelog -t "RunSettings: Done" ; echo " ";
              fi;
              export kernel_cc=$CC64;
              export CROSS_COMPILE_ARM32=$CC
  esac
};

# Kernel Config
function getkconfig() {
  unset ERR
  echo -e "$WHITE -------------------------"
  echo -e "$THEME$BLD - Setup your Kernel:"
  echo -e "$WHITE -------------------------"
  echo " "
  cd $kbe_path/source; kbelog -t "RunSettings: Entered in $kbe_path/source" 
  select d in */; do test -n "$d" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
  if [ $kernel_arch = arm64 ] && [ ! -d $kbe_path/source/$d/arch/$kernel_arch/ ]; then
    echo " "
    echo -e "$RED$BLD   This Kernel Source doesn't contains 64bits defconfigs... Exiting...$RATT"
    echo " "; kbelog -t "RunSettings: This kernel source doesnt contains 64bits defconfig, exiting KB-E..." 
    cd $kbe_path; export CWK=n; ERR=1; return 1
  elif [ $kernel_arch = arm ] && [ ! -d $kbe_path/source/$d/arch/$kernel_arch/ ]; then
    echo " "
    echo -e "$RED$BLD   This Kernel Source doesn't contains 32bits defconfigs... Exiting...$RATT"
    echo " "; kbelog -t "RunSettings: This kernel source doesnt contains 32bits defconfig, exiting KB-E..." 
    cd $kbe_path; export CWK=n; ERR=1; return 1
  fi
  cd $kbe_path
  export kernel_source=$kbe_path/source/$d; kbelog -t "RunSettings: Exported kernel source to $kernel_source" 
  echo " "
  # Ask the user if he wants the original CrossCompiler output
  # or KB-E simplified output while building the kernel
  echo -e "   Show original CrossCompiler output?"
  echo -ne "   (While building Kernel)$THEME$BLD [Y/N]:$WHITE "
  read CCSHOW
  if [ $CCSHOW = y ] || [ $CCSHOW = Y ]; then
    export show_cc_out=true; kbelog -t "RunSettings: Showing original CrossCompiler output" 
  fi

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
  cd $kernel_source/arch/$kernel_arch/configs/; kbelog -t "RunSettings: Entered in $kernel_source/arch/$kernel_arch/configs" 
  select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
  cd $kbe_path
  export kernel_defconfig=$DEF; kbelog -t "RunSettings: Defconfig: $kernel_defconfig" 
  echo " "

  # Clear source on each build?
  echo -ne "   Clear Source on every Build?$THEME$BLD [Y/N]:$WHITE "
  read CLRS
  if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
    kbelog -t "RunSettings: Cleaning source on every build" 
    export clear_source_onbuild=true
  fi

  # Build DTB Manually?
  echo -ne "   Build DTB automatically? [Y/N]:$WHITE "
  read BDTB
  if [ "$BDTB" = "y" ] || [ "$BDTB" = "Y" ]; then
    kbelog -t "RunSettings: Building DTB Manually" 
    export kernel_build_dtb=true
  else
    export kernel_build_dtb=false
  fi
};

# Modules function
function getmodules() {
  kbelog -t "RunSettings: Entering modules selection" 
  echo -e "$WHITE --------------------------"
  echo -e "$THEME$BLD - Modules selection:"
  echo -e "$WHITE --------------------------"
  MLIST=$kbe_path/resources/other/modules.txt
  if [ -f $MLIST ]; then
    kbelog -t "RunSettings: Removing $MLIST file" 
    rm $MLIST
  fi
  kbelog -t "RunSettings: Creating $MLIST file" 
  touch $MLIST
  echo "# Modules Functions" > $MLIST
  k=1
  x=1
  for i in $kbe_path/modules/*.sh
  do
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
      echo "export MODULE$((k++))=$(grep MODULE_FUNCTION_NAME $i | cut -d '=' -f2)" >> $MLIST
      echo "export MPATH$((x++))=$i" >> $MLIST
      kbelog -t "RunSettings: Running '$(grep MODULE_NAME $i | cut -d '=' -f2)' module" 
      source $i
      # Save the path to execute the module, needed by device kernel_name file
      echo "source $i" >> $MLIST
    fi
  done
  kbelog -t "RunSettings: Exporting modules configuration" 
  source $MLIST
  kbelog -t "RunSettings: Done" 
};

# Lets start the config process here

promptdata; if [ "$ERR" = "1" ]; then unset ERR; return 1; fi; echo " "
getarch; echo " "
getcc;
getkconfig; if [ "$ERR" = "1" ]; then unset ERR; return 1; fi; echo " "

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
getmodules;
cat $MLIST >> $device_kernel_file

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
echo -e "$WHITE  --------------------------$THEME$BLD"
echo " "
read -p "   Press enter to continue..."
kbelog -t "RunSettings: All done" 
echo -ne "$WHITE"
