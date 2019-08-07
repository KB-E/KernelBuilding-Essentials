#!/bin/bash

# Install Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Create a first run file, KB-E will check for it 
touch $CDF/resources/other/firstrun
echo " "
log -t "Install: Starting a new first run config process..." $KBELOG
echo -e "$THEME$BLD - Install: Starting new first run config process... $WHITE"

# Load auto.sh function into .bashrc
log -t "Install: Writting KB-E config to ~/.bashrc" $KBELOG
echo " "
echo -ne "$THEME$BLD - Writting KB-E Config in ~/.bashrc...$WHITE"
sudo sed -i '/# Load KB-E Function and Path/d' ~/.bashrc
sudo sed -i '/CDF=/d' ~/.bashrc
sudo sed -i '/colors.sh/d' ~/.bashrc
sudo sed -i '/core.sh/d' ~/.bashrc
sudo sed -i '/log.sh/d' ~/.bashrc
echo "# Load KB-E Function and Path" >> ~/.bashrc
echo "CDF=$CDF" >> ~/.bashrc
echo "source $CDF/resources/other/colors.sh" >> ~/.bashrc
echo "source $CDF/resources/log.sh" >> ~/.bashrc
echo "source $CDF/core.sh --kbe" >> ~/.bashrc
echo -e " Done"

# Install necessary stuff
log -t "Install: Running InstallTools..." $KBELOG
installtools; log -t "Install: Running Clear" $KBELOG
clear; log -t "Install: Displaying Title" $KBELOG
title
echo " "
echo -e "$THEME$BLD - Tools Download Finished..."
sleep 1

# Check environment
log -t "Install: Checking Environment..." $KBELOG
checkdtbtool
checkziptool

# Same has the above code, if checkenviroment doesn't detects the DTB tool, then
# this time, the user deleted it or its corrupt, if that's the case, the user must
# download dtbToolLineage again or re-download this script
if [ "$NODTB" = 1 ]; then
  log -t "Install: No DTB Tool Found" $KBELOG
  echo " "
  echo -e "$RED   dtbToolLineage not found... this is is beacuse its corrupt or the user "
  echo -e "   deleted it, please, download it again or re-download this program"
  echo " "
fi

echo " "; log -t "Install: Displaying user FirstRun information" $KBELOG
echo -e "$THEME$BLD   ---------------------------------------------------------------------------"
echo -e "$WHITE   Your Kernel source goes in the ./source folder, you can download there all"
echo -e "   the kernel sources you want, this program will prompt you which one you're"
echo -e "   going to build every session"
echo -e "$THEME$BLD   ---------------------------------------------------------------------------"
echo " "
echo -e "$THEME$BLD   ---------------------------------------------------------------------------"
echo -e "$WHITE   Also, every session this program will prompt to you things like the kernel  "
echo -e "   name, version, target android, build type, etc... You can skip all of this"
echo -e "   by using the 'auto <device>' command, this program has been made to make "
echo -e "   everything you need automatically."
echo -e "$THEME$BLD   ---------------------------------------------------------------------------"
echo " "
read -p "   Press enter to continue..."
echo " "
echo -e "$THEME$BLD   ---------------------------------------------------------------------------"
echo -e "$WHITE   First run is done, run the command 'kbhelp' for more information and run"
echo -e "   this program again!"
echo -e "$THEME$BLD   ---------------------------------------------------------------------------$RATT"
sleep 4
log -t "Install: All done" $KBELOG
export FRF=1
