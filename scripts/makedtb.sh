# Script to make Kernel DTB
# By Artx/Stayn <jesusgabriel.91@gmail.com>

build_dtb () {
  if [ "$STOP" = 1 ]; then
    export STOP=0
    echo -e "$RED$BLD - Stopping dtb Building..."
    return 1
  fi
# Remove old dt.img from kernel source
if [ -f $P/arch/arm/boot/dt.img ]; then
rm $P/arch/arm/boot/dt.img &> /dev/null
fi

# Build with Lineage dtbTool
if [ -f $DTB ]; then
  chmod 777 $DTB
  echo -e "$GREEN$BLD - Building DTB with dtbToolLineage...$RATT$WHITE"
  $DTB -2 -o $P/arch/arm/boot/dt.img -s 2048 -p $P/scripts/dtc/ $P/arch/arm/boot/ &> $LOGF/build-dtb_log.txt
  echo -e "   Done"
fi

# Verify dt.img
if [ ! -f $P/arch/arm/boot/dt.img ]; then
  echo -e "$RED$BLD   Create dt.img failed!$RATT$WHITE"
  read -p "   Read build-dtb_log? [y/n]: " RDDTB
  if [ $RDDTB = y ] || [ $RDDTB = Y ]; then
    nano $LOGF/build-dtb_log.txt
  fi
  echo " "
  return 1
else
  mv $P/arch/arm/boot/dt.img $DT
  echo " "
  echo -e "$GREEN$BLD - Sucessufully generated dt.img $RATT$WHITE"
  echo " "
fi
}

# Done
echo -e "$WHITE * Function 'build_dtb' Loaded$RATT"
