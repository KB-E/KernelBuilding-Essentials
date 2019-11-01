#!/bin/bash

# Script to make Kernel DTB
# By Artx/Stayn <jesusgabriel.91@gmail.com>

function compiledtb() {
  checkdtbtool
  dtb_code=$kbe_path/resources/dtbtool/dtbtool.c
  dtb_binary=$kbe_path/resources/dtbtool/dtbtool
  dtb_compiled=$kbe_path/resources/dtbtool/dtbtool.o
  if [ ! -f $dtb_binary ]; then
    echo -e "$WHITE   Compiling DTB Tool..."; kbelog -t "CompileDTB: Compiling DTB Tool..."
    gcc -c $dtb_code -o $dtb_compiled; if [ -f $dtb_compiled ]; then kbelog -t "CompileDTB: dtbtool.o found"; fi
    gcc $dtb_compiled -o dtbtool && mv dtbtool $(dirname $dtb_binary); if [ -f $dtb_binary ]; then kbelog -t "CompileDTB: dtbtool build done"; fi
    if [ ! -f $dtb_binary ]; then
      echo -e "$RED$BLD   Error: DTB Tool compile failed"
      export dtb_compile_failed=true; kbelog -t "CompileDTB: DTB Tool compile failed"
    fi
    echo -e "$WHITE   Done$RATT"
  else
    echo -e "$WHITE   DTB Tool binary found$RATT"; kbelog -t "CompileDTB: DTB Tool binary found"
  fi
}
export -f compiledtb; kbelog -f compiledtb

function makedtb() {
  DTB=$kbe_path/resources/dtbtool/dtbtool
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
    $DTB -2 -o $kernel_source/arch/$kernel_arch/boot/dt.img -s 2048 -p $kernel_source/scripts/dtc/ $kernel_source/arch/$kernel_arch/boot/ &> $kbe_path/logs/build-dtb_log.txt
  elif [ $kernel_arch = arm64 ]; then
    $DTB -2 -o $kernel_source/arch/$kernel_arch/boot/dt.img -s 2048 -p $kernel_source/scripts/dtc/ $kernel_source/arch/$kernel_arch/boot/dts/qcom/ &> $kbe_path/logs/build-dtb_log.txt
  fi

  # Create out folder for this device
  if [ ! -d $DTOUT ]; then
    mkdir $DTOUT
  fi

  # Verify dt.img
  if [ ! -f $kernel_source/arch/$kernel_arch/boot/dt.img ]; then
    echo " "; kbelog -t "MakeDTB: Error: DTB Build failed, exiting..."
    echo -e "$RED Error: DTB Build failed or no unique DTB(s) were found$RATT$WHITE"
    echo -e "$RATT"
    # Report DTB Build failed to KB-E
    export dtb_build_failed=true
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
