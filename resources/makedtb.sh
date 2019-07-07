#!/bin/bash

# Script to make Kernel DTB
# By Artx/Stayn <jesusgabriel.91@gmail.com>

function compiledtb() {
  checkdtbtool
  DTBF=$CDF/resources/dtbtool/dtbtool.c
  DTBB=$CDF/resources/dtbtool/dtbtool
  DTBC=$CDF/resources/dtbtool/dtbtool.o
  if [ ! -f $DTBB ]; then
    echo -e "$WHITE   Compiling DTB Tool..."; log -t "CompileDTB: Compiling DTB Tool..." $KBELOG
    gcc -c $DTBF -o $DTBC; if [ -f $DTBC ]; then log -t "CompileDTB: dtbtool.o found" $KBELOG; fi
    gcc $DTBC -o dtbtool && mv dtbtool $(dirname $DTBB); if [ -f $DTBB ]; then log -t "CompileDTB: dtbtool build done" $KBELOG; fi
    if [ ! -f $DTBB ]; then
      echo -e "$RED$BLD   Error: DTB Tool compile failed"
      export NODTB=1; log -t "CompileDTB: DTB Tool compile failed" $KBELOG
    fi
    echo -e "$WHITE   Done$RATT"
  else
    echo -e "$WHITE   DTB Tool binary found$RATT"; log -t "CompileDTB: DTB Tool binary found" $KBELOG
  fi
}
export -f compiledtb; log -f compiledtb $KBELOG

function makedtb() {
  DTB=$CDF/resources/dtbtool/dtbtool
  echo -ne "$THEME$BLD"
  echo -e "   ___ _____ ___  " 
  echo -e "  |   \_   _| _ ) "
  echo -e "  | |) || | | _ \ "
  echo -e "  |___/ |_| |___/ "
  echo " "
  echo -e "$THEME$BLD   --------------------------$WHITE"
  echo -e "$WHITE$BLD - Build $THEME$BLD DTB$WHITE Script"
  echo -e "   Kernel:$THEME$BLD $KERNELNAME$WHITE; Variant:$THEME$BLD $VARIANT$WHITE; Date:$THEME$BLD $DATE$WHITE"
  # Remove old dt.img from kernel source
  if [ -f $P/arch/$ARCH/boot/dt.img ]; then
   rm $P/arch/$ARCH/boot/dt.img; log -t "MakeDTB: Removed old dt.img" $KBELOG
   echo -e "   Removed old DTB"
  fi

  # Build with Lineage dtbTool 
  chmod 777 $DTB
  log -t "MakeDTB: Building DTB with dtbToolLineage" $KBELOG
  echo -e "$WHITE   Building DTB...$RATT$WHITE"
  if [ $ARCH = arm ]; then
    $DTB -2 -o $P/arch/$ARCH/boot/dt.img -s 2048 -p $P/scripts/dtc/ $P/arch/$ARCH/boot/ &> $LOGF/build-dtb_log.txt
  elif [ $ARCH = arm64 ]; then
    $DTB -2 -o $P/arch/$ARCH/boot/dt.img -s 2048 -p $P/scripts/dtc/ $P/arch/$ARCH/boot/dts/qcom/ &> $LOGF/build-dtb_log.txt
  fi

  # Create out folder for this device
  if [ ! -d $DTOUT ]; then
    mkdir $DTOUT
  fi

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
   mv $P/arch/$ARCH/boot/dt.img $DTOUT/$VARIANT; log -t "MakeDTB: New DTB moved to '$DTOUT' named '$VARIANT'" $KBELOG
   echo -e "   Done$RATT"
   echo -e "$THEME$BLD   --------------------------$WHITE"
   echo " "; log -t "MakeDTB: All done" $KBELOG
  fi
}
export -f makedtb; log -f makedtb $KBELOG
# Define dt out path
DTOUT=$CDF/devices/$KERNELNAME/out/dt
