#!/bin/bash

# FirstRun Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Create a first run file, KB-E will check for it 
touch ./resources/other/firstrun
echo " "
echo -e "$GREEN - It seems that you're running this program for the first time"
echo -e "   Lets install some necessaty stuff... $WHITE"

# Load auto.sh function into .bashrc
echo " "
echo -ne "$GREEN$BLD - Writting KB-E Config in ~/.bashrc...$WHITE"
sudo sed -i '/# Load auto.sh function and path/d' ~/.bashrc
sudo sed -i '/CDF=$CDF/d' ~/.bashrc
sudo sed -i '/. $CDF/resources/other/colors.sh/d' ~/.bashrc
sudo sed -i '/. $CDF/auto.sh/d' ~/.bashrc
echo "# Load auto.sh function and path" >> ~/.bashrc
echo "CDF=$CDF" >> ~/.bashrc
echo ". $CDF/resources/other/colors.sh" >> ~/.bashrc
echo ". $CDF/auto.sh" >> ~/.bashrc
. $CDF/auto.sh
echo -e " Done"
echo " "

# Install necessary stuff
installtools
echo -e "   Done, let's begin with some initial configuration..."
sleep 1

# Generate enviroment folders
checkfolders
checkenvironment
megacheck

# If checkenviroment exports CERROR=1 then, crosscompiler isn't configured
# because it's the first run, but, if it's configured before the first run
# then, there's no need for help
if [ "$CERROR" =  1 ]; then
  echo " "
  echo -e "$WHITE - There's no CrossCompiler available for the KernelBuilding process"
  echo -e "   But don't worry, this program will prompt to you which one you want"
  echo -e "   to download (arm or arm64) for your future buildings!"
  echo " "
fi

# Same has the above code, if checkenviroment doesn't detects the DTB tool, then
# this time, the user deleted it or its corrupt, if that's the case, the user must
# download dtbToolLineage again or re-download this script
if [ "$NODTB" = 1 ]; then
  echo -e "$RED   dtbToolLineage not found... this is is beacuse its corrupt or the user "
  echo -e "   deleted it, please, download it again or re-download this program"
fi
echo -e "$WHITE   Your Kernel source goes in the ./source folder, you can download there all the"
echo -e "   kernel sources you want, this program will prompt you which one you're "
echo -e "   going to build every session"
echo " "
echo -e "   Also, every session this program will prompt to you things like the kernel name, version,"
echo -e "   target android, build type, etc... You can skip all of this by enabling the variable "
echo -e "   'DSENABLED' in ./defaultsettings.sh and configuring it at your please, this program has"
echo -e "   been made to make everything you need automatically."
echo -e "$GREEN"
read -p "   Press enter to continue..."
echo " "
echo -e "$WHITE   First run is done, run the command 'kbhelp' for more information and run this"
echo -e "   program again!"
export FRF=1