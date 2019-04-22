#!/bin/bash

# FirstRun Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Create a first run file, KB-E will check for it 
touch $CDF/resources/other/firstrun
echo " "
log -t "FirstRun: Starting a new first run config process..." $KBELOG
echo -e "$GREEN$BLD - FirstRun: Starting new first run config process... $WHITE"

# Load auto.sh function into .bashrc
log -t "FirstRun: Running WriteProgramConfig..." $KBELOG
writeprogramconfig

# Install necessary stuff
log -t "FirstRun: Running InstallTools..." $KBELOG
installtools; log -t "FirstRun: Running Clear" $KBELOG
clear; log -t "FirstRun: Displaying Title" $KBELOG
title
echo " "
echo -e "$GREEN$BLD - Tools Download Finished..."
sleep 1

# Check environment
log -t "FirstRun: Checking Environment..." $KBELOG
checkdtbtool
checkziptool

# Same has the above code, if checkenviroment doesn't detects the DTB tool, then
# this time, the user deleted it or its corrupt, if that's the case, the user must
# download dtbToolLineage again or re-download this script
if [ "$NODTB" = 1 ]; then
  log -t "FirstRun: No DTB Tool Found" $KBELOG
  echo " "
  echo -e "$RED   dtbToolLineage not found... this is is beacuse its corrupt or the user "
  echo -e "   deleted it, please, download it again or re-download this program"
  echo " "
fi

echo " "; log -t "FirstRun: Displaying user FirstRun information" $KBELOG
echo -e "$GREEN$BLD   ---------------------------------------------------------------------------"
echo -e "$WHITE   Your Kernel source goes in the ./source folder, you can download there all"
echo -e "   the kernel sources you want, this program will prompt you which one you're"
echo -e "   going to build every session"
echo -e "$GREEN$BLD   ---------------------------------------------------------------------------"
echo " "
echo -e "$GREEN$BLD   ---------------------------------------------------------------------------"
echo -e "$WHITE   Also, every session this program will prompt to you things like the kernel  "
echo -e "   name, version, target android, build type, etc... You can skip all of this"
echo -e "   by using the 'auto <device>' command, this program has been made to make "
echo -e "   everything you need automatically."
echo -e "$GREEN$BLD   ---------------------------------------------------------------------------"
echo " "
read -p "   Press enter to continue..."
echo " "
echo -e "$GREEN$BLD   ---------------------------------------------------------------------------"
echo -e "$WHITE   First run is done, run the command 'kbhelp' for more information and run"
echo -e "   this program again!"
echo -e "$GREEN$BLD   ---------------------------------------------------------------------------"
log -t "FirstRun: All done" $KBELOG
export FRF=1
