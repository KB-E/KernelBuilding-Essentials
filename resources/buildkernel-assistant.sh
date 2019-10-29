#!/bin/bash

# Kernel building script methods
# By Artx/Stayn <artx4dev@gmail.com>

# Remove log file if it exist
if [ -f $kernel_source/log.txt ]; then
  rm $kernel_source/log.txt
fi

# Create new log file
touch $kbe_path/logs/build-assistant_log.txt

# Function to clear last line
function clearlastline() {
        printf "%*s\r" && tput el
}

# Function to compile kernel
function compile_kernel() {
  # Start compiling kernel, outdirected to log.txt
  # to analyse it while its building
  make -j$(nproc) ARCH=$kernel_arch &>> $kbe_path/logs/build-assistant_log.txt
  # Done, tell klog_analysis we're done
  echo "compiling done" >> $kbe_path/logs/build-assistant_log.txt
}

# Function to analyse the CrossCompiler output
function klog_analysis() {
  # Keep track of Kernel building log.txt file
  tail -f $kbe_path/logs/build-assistant_log.txt | while read LOGLINE
  do
     # This code detects something beign compiled and outputs
     # information for the user without spamming
     filename=$(echo $LOGLINE | sed 's/.*://' | cut -d ' ' -f2)
     filename=$(basename $filename 2> /dev/null)
     [[ "${LOGLINE}" == *"drivers/"* ]]  && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Driver:        > $filename "
     [[ "${LOGLINE}" == *"sound/"* ]]    && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Sound:         > $filename "
     [[ "${LOGLINE}" == *"mm/"* ]]       && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Memory Model:  > $filename "
     [[ "${LOGLINE}" == *"arch/"* ]]     && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Arch:          > $filename "
     [[ "${LOGLINE}" == *"block/"* ]]    && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Block:         > $filename "
     [[ "${LOGLINE}" == *"firmware/"* ]] && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Firmware:      > $filename "
     [[ "${LOGLINE}" == *"net/"* ]]      && clearlastline && printf "$b" "   $THEME[CC]$WHITE - Net:           > $filename "
     [[ "${LOGLINE}" == *"crypto/"* ]]   && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Crypto:        > $filename "
     [[ "${LOGLINE}" == *"fs/"* ]]       && clearlastline && printf "%b" "   $THEME[CC]$WHITE - File System:   > $filename "
     [[ "${LOGLINE}" == *"security/"* ]] && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Security:      > $filename "
     [[ "${LOGLINE}" == *"kernel/"* ]]   && clearlastline && printf "$b" "   $THEME[CC]$WHITE - Kernel:        > $filename "
     [[ "${LOGLINE}" == *"ipc/"* ]]      && clearlastline && printf "%b" "   $THEME[CC]$WHITE - IPC:           > $filename "
     [[ "${LOGLINE}" == *"include/"* ]]  && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Include:       > $filename "
     [[ "${LOGLINE}" == *"init/"* ]]     && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Init:          > $filename "
     [[ "${LOGLINE}" == *"tools/"* ]]    && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Tools:         > $filename "
     [[ "${LOGLINE}" == *"user/"* ]]     && clearlastline && printf "%b" "   $THEME[CC]$WHITE - User:          > $filename "
     [[ "${LOGLINE}" == *"lib/"* ]]      && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Lib:           > $filename "
     [[ "${LOGLINE}" == *"samples/"* ]]  && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Samples        > $filename "
     [[ "${LOGLINE}" == *"virt/"* ]]     && clearlastline && printf "%b" "   $THEME[CC]$WHITE - Virt:          > $filename "

     # This code breaks this while cycle when compile_kernel
     # it's done
     [[ "${LOGLINE}" == *"compiling done"* ]] && break

     # This code is for error checking and asistance (soon)
  done
}

# Old code
#klog_analisis & compile && kill $!
#$(analisis && pid1="$!") & $(compile && pid2="$!") & kill $pid1 && kill $pid2

# Start processes in parallel
klog_analysis & compile_kernel && fg
