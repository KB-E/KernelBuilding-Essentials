#!/bin/bash
# Session settings
# By Artx <artx4dev@gmail.com>

# Clear Variables (Just in case)
kbelog -t "RunSettings: Clearing variables" 
unset kernel_name; unset target_android; unset kernel_version; unset device_variant; unset kernel_defconfig;
unset BLDTYPE; unset kernel_source; unset; unset clear_source_onbuild; unset ARMT; unset kernel_arch
unset kernel_build_dtb; unset release_type; unset AKBO; unset show_cc_out; unset RD; unset release_type;

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

# Let's initialize a new device
getusrbasics; if [ "$ERR" = "1" ]; then export ERR="Couldn't get Basic info"; return 1; fi; echo " "
checksource;
if [ "$available_kernel_source" = "false" ]; then
  echo -e "$RED$BLD   Warning:$WHITE no Kernel source found"
  echo -ne "   Continue without it?$THEME$BLD [y/n]:$WHITE "; read cont
  echo " "
  if [ "$cont" = "y" ] || [ "$cont" = "Y" ]; then
    unset cont
  else
    unset cont
    return 1
  fi
else
  getkconfig; if [ "$ERR" = "1" ]; then export ERR="Couldn't get Kernel config"; return 1; fi; echo " "
fi
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
