# Predefined config for KB-E
# By Artx/Stayn <jesusgabriel.91@gmail.com>

#  You can set predefined configs here
#  if you enable this file the program will take
#  your preferences from here instead of prompting
#  you in each run

DSENABLED=0 # (defaultsettings enable switch, 1 = Enabled; 0 = Disabled)

# Force the execution of runsettings.sh for the first run, don't touch this
if [ ! -f ./resources/other/firstrun ]; then
  DSENABLED=0
fi

if [ $DSENABLED = 1 ]; then
  export AUSETTINGS=0 # This variable tells the program to prompt user for this session settings
                      # and exit this script
else
  export AUSETTINGS=1
  return 1
fi
echo
echo -e "$GREEN - Loading predefined settings..."
sleep 0.5

# Config required to Build kernel and Zip file
KERNELNAME=
TARGETANDROID=
VERSION=
VARIANT=

# Debug Kernel Building?
KDEBUG=

# Make dtb? (1 = Enabled; 0 = Disabled)
MAKEDTB=

# Build zips type (A = AROMA; K = AnyKernel)
BLDTYPE=K

## IMPORTANT ##
# Select and option (1 = Local Anykernel template; 2 = Download Anykernel template from MEGA; 3 = Set it manually)
DLTO=1

if [ "$DLTO" = "1" ]; then
# If theres this file missing we can assume that the template is broken or
# we have to extract a new one into ./out/aktemplates
if [ ! -f $AKT/anykernel.sh ]; then
templatesconfig
fi
# Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
export TF=$AKT
fi

if [ "$DLTO" = "2" ]; then
# If theres this file missing we can assume that the template is broken or
# we have to extract a new one into ./out/mega_aktemplates
if [ ! -f $MAKT/anykernel.sh ]; then
megadlt
fi
# Tell the makeanykernel script to use the "./out/mega_aktemplates folder for anykernel building"
export TF=$MAKT
fi

if [ "$DLTO" = "3" ]; then
# Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
export TF=$AKT
fi

# Kernel source Path
P=$CDF/
# ------------------

# Kernel ARCH Type
ARCH= # (arm = 32bits ARM; arm64 = 64bits ARM)

# This will export the correspondent CrossCompiler for the ARCH Type
if [ "$ARCH" = "arm" ]; then
  CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi- # arm CrossCompiler
  # Check
  if [ ! -f "$CROSSCOMPILE"gcc ]; then
    echo -e "$RED - Cross Compiler not found ($CROSSCOMPILE)"
    downloadcc
  fi
elif [ "$ARCH" = "arm64" ]; then
  CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-
  # Check 
  if [ ! -f "$CROSSCOMPILE"gcc ]; then
    echo -e "$RED - Cross Compiler not found ($CROSSCOMPILE) $WHITE"
    downloadcc
  fi
fi

# Clean Source on each compiling process?
CLR=

## MEGA Config ## (For Automatically Download your Template)

# Done
echo -e "$WHITE   Done"

