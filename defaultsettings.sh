# Predefined config for KB-E
# By Artx/Stayn <jesusgabriel.91@gmail.com>

#  You can set predefined configs here
#  if you enable this file the program will take
#  your preferences from here instead of prompting
#  you in each run

DSENABLED=0 # (defaultsettings enable switch, 1 = Enabled; 0 = Disabled)

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
KERNELNAME=ArtxUltra
TARGETANDROID=Oreo
VERSION=1.0
VARIANT=d851

# Debug Kernel Building?
KDEBUG=1

# Make dtb? (1 = Enabled; 0 = Disabled)
MAKEDTB=1

# Build zips type (A = AROMA; K = AnyKernel)
BLDTYPE=K

# Download zips from MEGA?


# Kernel source Path
P=$CDF/"source/artixo/"
# ------------------

# Kernel CrossCompiler and ARCH Type
# This will override the predefined paths in ./resources/paths.sh for crosscompiler and arch
CROSSCOMPILE=$CDF/"crosscompiler/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
ARCH=arm

# Clean Source on each compiling process?
CLR=0

# Done
echo -e "$WHITE   Done"
