#!/bin/bash

# FirstRun Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Create a first run file, KB-E will check for it 
touch $CDF/resources/other/firstrun
echo " "
echo -e "$GREEN - FirstRun: Starting new first run config process... $WHITE"

# Load auto.sh function into .bashrc
writeprogramconfig

# Install necessary stuff
installtools
echo -e "$GREEN$BLD - Done, let's begin with some initial config..."
sleep 1

# Check environment
checkfolders
checkdtbtool
checkziptool
megacheck

# Same has the above code, if checkenviroment doesn't detects the DTB tool, then
# this time, the user deleted it or its corrupt, if that's the case, the user must
# download dtbToolLineage again or re-download this script
if [ "$NODTB" = 1 ]; then
  echo " "
  echo -e "$RED   dtbToolLineage not found... this is is beacuse its corrupt or the user "
  echo -e "   deleted it, please, download it again or re-download this program"
  echo " "
fi

echo -e "$GREEN   ---------------------------------------------------------------------------"
echo -e "$WHITE   Your Kernel source goes in the ./source folder, you can download there all"
echo -e "   the kernel sources you want, this program will prompt you which one you're"
echo -e "   going to build every session"
echo -e "$GREEN   ---------------------------------------------------------------------------"
echo " "
echo -e "$GREEN   ---------------------------------------------------------------------------"
echo -e "$WHITE   Also, every session this program will prompt to you things like the kernel  "
echo -e "   name, version, target android, build type, etc... You can skip all of this"
echo -e "   by using the 'auto <device>' command, this program has been made to make "
echo -e "   everything you need automatically."
echo -e "$GREEN   ---------------------------------------------------------------------------"
echo " "
read -p "   Press enter to continue..."
echo " "
echo -e "$GREEN   ---------------------------------------------------------------------------"
echo -e "$WHITE   First run is done, run the command 'kbhelp' for more information and run"
echo -e "   this program again!"
echo -e "$GREEN   ---------------------------------------------------------------------------"

export FRF=1