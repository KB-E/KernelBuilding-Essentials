#!/bin/bash

# Script to make Kernel DTB
# By Artx/Stayn <jesusgabriel.91@gmail.com>

makedtb () {
  echo -ne "$GREEN$BLD"
  echo -e "   ___ _____ ___  " 
  echo -e "  |   \_   _| _ ) "
  echo -e "  | |) || | | _ \ "
  echo -e "  |___/ |_| |___/ "
  echo " "
  echo " "
  echo -e "$GREEN$BLD - Build DTB Script for $VARIANT "

  # Check DTB Tool
  checkdtbtool

  # Remove old dt.img from kernel source
  if [ -f $P/arch/$ARCH/boot/dt.img ]; then
   rm $P/arch/$ARCH/boot/dt.img
  fi

  # Build with Lineage dtbTool 
  chmod 777 $DTB
  echo " "
  echo -ne "$WHITE   Building DTB with dtbToolLineage...$RATT$WHITE"
  $DTB -2 -o $P/arch/$ARCH/boot/dt.img -s 2048 -p $P/scripts/dtc/ $P/arch/$ARCH/boot/ &> $LOGF/build-dtb_log.txt

  # Verify dt.img
  if [ ! -f $P/arch/$ARCH/boot/dt.img ]; then
    echo " "
    echo -e "$RED Error: DTB Build failed or no unique DTB(s) were found$RATT$WHITE"
    read -p "   Read build-dtb_log? [y/n]: " RDDTB
    if [ $RDDTB = y ] || [ $RDDTB = Y ]; then
     nano $LOGF/build-dtb_log.txt
     unset RDDTB
    fi
    echo -e "$RATT"
    # Report DTB Build failed to KB-E
    export DTBFAILED=1
    return 1
  else
   mv $P/arch/$ARCH/boot/dt.img $DT/$VARIANT
   echo -e "$GREEN$BLD Done$RATT"
   echo " "
  fi
}
export -f makedtb
