# Kernel building script methods
# By Artx/Stayn <jesusgabriel.91@gmail.com>

buildkernel () {
  if [ "$STOP" = 1 ]; then
    export STOP=0
    echo -e "$RED$BLD - Stopping Kernel Building..."
    return 1
  fi
  checkenvironment
  echo " "
  echo -e "$LCYAN$BLD  ## $KERNELNAME Kernel Building Script ##"
  echo -e "$LCYAN$BLD  ## Version: $VERSION for $TARGETANDROID ROM's ## $RATT$WHITE"
  echo " "
if [ "$CERROR" = 1 ]; then # This exported variable means that the CrossCompiler
                         # were not found and we cannot compile the kernel
  echo -e "$RED - There was an error getting the CrossCompiler path, exiting...$RATT"
  echo " "
  return 1
fi

# Enter in the kernel source
if [ -d $P ]; then # P = Path for Kernel defined by the user
                   # in the process or defaultsettings.sh
  cd $P
  echo -e "$GREEN$BLD - Entered in $WHITE'$P' $GREEN$BLDSucessfully"
  echo " "
else # If it doesnt exist it means that we don't have nothing to do
  echo -e "$RED   Path doesn't exist!"
  echo -e "$RED - Build canceled$RATT"
  echo " "
  return 1
fi

# Export necessary things
export ARCH=$ARCH                   # If the program succed at this step, this means
#echo -e "$WHITE   Exported $ARCH"
export CROSS_COMPILE=$CROSSCOMPILE  # that we can start compiling the kernel!
#echo -e "   Exported $CROSSCOMPILE"

#Start Building Process
if [ "$CLR" = 1 ]; then make clean; echo " "; fi # Clean Kernel source, this variable
                                               # is defined in config.sh
# To avoid a false sucessfull build
rm arch/arm/boot/zImage &> /dev/null
# ---------------------------------

# Load defconfig
echo -e "$GREEN$BLD Loading Defconfig for $VARIANT...$RATT$WHITE"
echo " "
# Load $VARIANT defconfig
make lineageos_"$VARIANT"_defconfig &>> $LOGF/buildkernel_log.txt
# -----------------------

# Start compiling kernel
echo -e "$GREEN$BLD Compiling... This may take a while...$RATT$WHITE"
make CONFIG_NO_ERROR_ON_MISMATCH=y $1 &>> $LOGF/buildkernel_log.txt # Store logs
echo " Done"                       # $NJOBS = Number of processor cores
echo " "                           # defined in config.sh

# Verify if the kernel were built
KERROR=0
if [ ! -f ./arch/arm/boot/zImage ]; then # If theres no zImage built then there was
  export KERROR=1                          # an error compiling the kernel
       # KERROR will alert other scripts
       # that the kernel build failed
  echo " "
  echo -e "$RED$BLD ## Build for $VARIANT Failed, Opening buildkernel_log.txt For Details... ## $WHITE"
  echo " " &>> $LOGF/buildkernel_log.txt
  echo "KERNEL BUILDING FAILED" &>> $LOGF/buildkernel_log.txt
  read -p "Read building log? [y/n]: " READBL  # Prompt the user to see the failed
  if [ $READBL = y ] || [ $READBL = y ]; then  # kernel build log
    nano $LOGF/buildkernel_log.txt
  fi
fi

# If KERROR is not equal to 1 then we can proceed to
# move the kernel in their respective folders
if [ "$KERROR" != 1 ]; then
  if [ -f $ZIN/$VARIANT ]; then
    mv $ZIN/$VARIANT $ZI/$VARIANT
    echo -e "$BLUE$BLD - Moved old $VARIANT Kernel to $ZI"
    echo " "
  fi
  cp arch/arm/boot/zImage $ZIN/$VARIANT
  echo -e "$WHITE$BLD - New Kernel Copied to $ZIN"
  echo " "
  echo -e "$GREEN ## Kernel for $VARIANT done ##$RATT"
  echo " "
else # Else, finish the function with a kernel building failed!
  echo " "
  echo -e "$RED ## Kernel Building Failed ##$RATT"
  echo " "
fi
cd $CDF
}

buildkernel_debug () {
  if [ "$STOP" = 1 ]; then
    export STOP=0
    echo -e "$RED$BLD - Stopping Kernel Building..."
    return 1
  fi
  echo " "
  echo -e "$LCYAN$BLD  ## $KERNELNAME Kernel Building Script ##"
  echo -e "$LCYAN$BLD  ## Version: $VERSION for $TARGETANDROID ROM's ## $RATT$WHITE"
  echo " "
if [ "$CERROR" = 1 ]; then # This exported variable means that the CrossCompiler
                           # were not found and we cannot compile the kernel
  echo -e "$RED - There was an error getting the CrossCompiler path, exiting...$RATT"
  echo " "
  return 1
fi

# Enter in the kernel source
if [ -d $P ]; then # P = Path for Kernel defined by the user
                   # in the process or defaultsettings.sh
  cd $P
  echo -e "$GREEN$BLD - Entered in $WHITE'$P' $GREEN$BLDSucessfully"
  echo " "
else # If it doesnt exist it means that we don't have nothing to do
  echo -e "$RED   Path doesn't exist!"
  echo -e "$RED - Build canceled$RATT"
  echo " "
  return 1
fi

# Export necessary things
export ARCH=$ARCH
#echo -e "$WHITE   Exported $ARCH"                   # If the program succed at this step, this means
export CROSS_COMPILE=$CROSSCOMPILE  # that we can start compiling the kernel!
#echo -e "   Exported $CROSSCOMPILE"

#Start Building Process
if [ "$CLR" = 1 ]; then make clean; echo " "; fi # Clean Kernel source, this variable
                                               # is defined in config.sh
# To avoid a false sucessfull build
rm arch/arm/boot/zImage &> /dev/null
# ---------------------------------

# Load defconfig
echo -e "$GREEN$BLD Loading Defconfig for $VARIANT...$RATT$WHITE"
echo " "
# Load $VARIANT defconfig
make lineageos_"$VARIANT"_defconfig
# -----------------------

# Start compiling kernel
echo -e "$GREEN$BLD Compiling... This may take a while...$RATT$WHITE"
make CONFIG_NO_ERROR_ON_MISMATCH=y $1
echo " Done"                       # $NJOBS = Number of processor cores
echo " "                           # defined in config.sh

# Verify if the kernel were built
KERROR=0
if [ ! -f ./arch/arm/boot/zImage ]; then # If theres no zImage built then there was
  export KERROR=1                          # an error compiling the kernel
       # KERROR will alert other scripts
       # that the kernel build failed
fi

# If KERROR is not equal to 1 then we can proceed to
# move the kernel in their respective folders
if [ "$KERROR" != 1 ]; then
  if [ -f $ZIN/$VARIANT ]; then
    mv $ZIN/$VARIANT $ZI/$VARIANT
    echo -e "$BLUE$BLD - Moved old $VARIANT Kernel to $ZI"
    echo " "
  fi
  cp arch/arm/boot/zImage $ZIN/$VARIANT
  echo -e "$WHITE$BLD - New Kernel Copied to $ZIN"
  echo " "
  echo -e "$GREEN ## Kernel for $VARIANT done ##$RATT"
  echo " "
else # Else, finish the function with a kernel building failed!
  echo " "
  echo -e "$RED ## Kernel Building Failed ##$RATT"
  echo " "
fi
cd $CDF
}

# Done here
echo -e "$WHITE * Function 'buildkernel' Loaded$RATT"
echo -e "$WHITE * Function 'buildkernel_debug' Loaded$RATT"
