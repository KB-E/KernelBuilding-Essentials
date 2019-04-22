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
  log -t "MakeDTB: Checking DTB Tool..." $KBELOG
  checkdtbtool
  log -t "MakeDTB: Done" $KBELOG

  # Remove old dt.img from kernel source
  if [ -f $P/arch/$ARCH/boot/dt.img ]; then
   rm $P/arch/$ARCH/boot/dt.img; log -t "MakeDTB: Removed old dt.img" $KBELOG
  fi

  # Build with Lineage dtbTool 
  chmod 777 $DTB
  echo " "; log -t "MakeDTB: Building DTB with dtbToolLineage" $KBELOG
  echo -ne "$WHITE   Building DTB with dtbToolLineage...$RATT$WHITE"
  $DTB -2 -o $P/arch/$ARCH/boot/dt.img -s 2048 -p $P/scripts/dtc/ $P/arch/$ARCH/boot/ &> $LOGF/build-dtb_log.txt

  # Verify dt.img
  if [ ! -f $P/arch/$ARCH/boot/dt.img ]; then
    echo " "; log -t "MakeDTB: Error: DTB Build failed, exiting..." $KBELOG
    echo -e "$RED Error: DTB Build failed or no unique DTB(s) were found$RATT$WHITE"
    read -p "   Read build-dtb_log? [y/n]: " RDDTB
    if [ $RDDTB = y ] || [ $RDDTB = Y ]; then
     log -t "MakeDTB: Opening DTB Build log to user" $KBELOG
     nano $LOGF/build-dtb_log.txt
     unset RDDTB
    fi
    echo -e "$RATT"
    # Report DTB Build failed to KB-E
    export DTBFAILED=1
    return 1
  else
   mv $P/arch/$ARCH/boot/dt.img $DT/$VARIANT; log -t "MakeDTB: New DTB moved to '$DT' named '$VARIANT'" $KBELOG
   echo -e "$GREEN$BLD Done$RATT"
   echo " "; log -t "MakeDTB: All done" $KBELOG
  fi
}
export -f makedtb
