#!/bin/bash

# Script to make Kernel DTB
# By Artx/Stayn <jesusgabriel.91@gmail.com>

function compiledtb() {
  checkdtbtool
  DTBF=$CDF/resources/dtbtool/dtbtool.c
  DTBB=$CDF/resources/dtbtool/dtbtool
  DTBC=$CDF/resources/dtbtool/dtbtool.o
  if [ ! -f $DTBB ]; then
    echo -e "$WHITE   Compiling DTB Tool..."; kbelog -t "CompileDTB: Compiling DTB Tool..."
    gcc -c $DTBF -o $DTBC; if [ -f $DTBC ]; then kbelog -t "CompileDTB: dtbtool.o found"; fi
    gcc $DTBC -o dtbtool && mv dtbtool $(dirname $DTBB); if [ -f $DTBB ]; then kbelog -t "CompileDTB: dtbtool build done"; fi
    if [ ! -f $DTBB ]; then
      echo -e "$RED$BLD   Error: DTB Tool compile failed"
      export NODTB=1; kbelog -t "CompileDTB: DTB Tool compile failed"
    fi
    echo -e "$WHITE   Done$RATT"
  else
    echo -e "$WHITE   DTB Tool binary found$RATT"; kbelog -t "CompileDTB: DTB Tool binary found"
  fi
}
export -f compiledtb; kbelog -f compiledtb

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
  echo -e "   Kernel:$THEME$BLD $kernel_name$WHITE; Variant:$THEME$BLD $device_variant$WHITE; Date:$THEME$BLD $DATE$WHITE"
  # Remove old dt.img from kernel source
  if [ -f $kernel_source/arch/$kernel_arch/boot/dt.img ]; then
   rm $kernel_source/arch/$kernel_arch/boot/dt.img; kbelog -t "MakeDTB: Removed old dt.img"
   echo -e "   Removed old DTB"
  fi

  # Build with Lineage dtbTool 
  chmod 777 $DTB
  kbelog -t "MakeDTB: Building DTB with dtbToolLineage"
  echo -e "$WHITE   Building DTB...$RATT$WHITE"
  if [ $kernel_arch = arm ]; then
    $DTB -2 -o $kernel_source/arch/$kernel_arch/boot/dt.img -s 2048 -p $kernel_source/scripts/dtc/ $kernel_source/arch/$kernel_arch/boot/ &> $LOGF/build-dtb_log.txt
  elif [ $kernel_arch = arm64 ]; then
    $DTB -2 -o $kernel_source/arch/$kernel_arch/boot/dt.img -s 2048 -p $kernel_source/scripts/dtc/ $kernel_source/arch/$kernel_arch/boot/dts/qcom/ &> $LOGF/build-dtb_log.txt
  fi

  # Create out folder for this device
  if [ ! -d $DTOUT ]; then
    mkdir $DTOUT
  fi

  # Verify dt.img
  if [ ! -f $kernel_source/arch/$kernel_arch/boot/dt.img ]; then
    echo " "; kbelog -t "MakeDTB: Error: DTB Build failed, exiting..."
    echo -e "$RED Error: DTB Build failed or no unique DTB(s) were found$RATT$WHITE"
    read -p "   Read build-dtb_log? [y/n]: " RDDTB
    if [ $RDDTB = y ] || [ $RDDTB = Y ]; then
     kbelog -t "MakeDTB: Opening DTB Build kbelog to user"
     nano $LOGF/build-dtb_log.txt
     unset RDDTB
    fi
    echo -e "$RATT"
    # Report DTB Build failed to KB-E
    export DTBFAILED=1
    return 1
  else
   mv $kernel_source/arch/$kernel_arch/boot/dt.img $DTOUT/$device_variant; kbelog -t "MakeDTB: New DTB moved to '$DTOUT' named '$device_variant'"
   echo -e "   Done$RATT"
   echo -e "$THEME$BLD   --------------------------$WHITE"
   echo " "; kbelog -t "MakeDTB: All done"
  fi
}
export -f makedtb; kbelog -f makedtb
# Define dt out path
DTOUT=$device_kernel_path/out/dt
