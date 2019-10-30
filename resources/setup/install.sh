#!/bin/bash
# KB-E Installation Script
# By Artx <artx4dev@gmail.com>

# Create a first run file, KB-E will check for it 
touch resources/other/firstrun; echo " "
kbelog -t "Install: Setting up KB-E..." 
echo -e "$THEME$BLD - Install: Starting new first run config process... $WHITE"

# Patch ~/.bashrc to load KB-E init file
if grep -q "# Load KB-E init file" ~/.bashrc; then
  echo " "; echo -e "$THEME$BLD - File ~/.bashrc is already patched..!$RATT"
else
  kbelog -t "Install: Patching ~/.bashrc"; echo " "
  echo -ne "$THEME$BLD - Patching ~/.bashrc to load init file...$WHITE"
  echo "# Load KB-E init file" >> ~/.bashrc
  echo "if [ -f $kbe_path/resources/init/init.sh ]; then" >> ~/.bashrc
  echo "  source $kbe_path/resources/init/init.sh" >> ~/.bashrc
  echo "fi" >> ~/.bashrc
  echo -e " Done$RATT"
fi
# Generate KB-E init file
kbelog -t "Install: Generating init.sh file"
INITPATH=resources/init/init.sh
if [ ! -f $INITPATH ]; then
  touch $INITPATH
fi
echo "#!/bin/bash" > $INITPATH
echo "" >> $INITPATH
echo "# KB-E init script" >> $INITPATH
echo "# This is automatically generated, do not edit" >> $INITPATH
echo "" >> $INITPATH
echo "# Load KB-E Function and Path" >> $INITPATH
echo "kbe_path=$kbe_path" >> $INITPATH
echo "source $kbe_path/resources/other/colors.sh" >> $INITPATH
echo "source $kbe_path/resources/log.sh" >> $INITPATH
echo "source $kbe_path/kbe.sh --init" >> $INITPATH
echo "complete -W 'start upgrade' kbe" >> $INITPATH
echo "" >> $INITPATH
echo "# Load configurable init script" >> $INITPATH
echo "if [ -f $kbe_path/resources/init/kbeinit.sh ]; then" >> $INITPATH
echo "  source $kbe_path/resources/init/kbeinit.sh" >> $INITPATH
echo "fi" >> $INITPATH

# Install necessary stuff
kbelog -t "Install: Installing dependencies..."; echo " "
sudo apt-get update
sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev device-tree-compiler ccache libc++-dev gcc
echo " "; kbelog -t "Install: Dependencies installed"

# Clear UI and display title
clear; kbelog -t "Install: Displaying Title"; title
echo " "
echo -e "$THEME$BLD - Tools Download Finished..."
sleep 1

# Check and if necessary, setup DTB Tool
kbelog -t "Install: Checking DTB Tool..."; echo " "
if [ ! -f resources/dtbtool/dtbtool.c ]; then # Check local dtbTool
  echo -e "$RED$BLD   DTB Tool source not found$RATT$WHITE"; kbelog -t "Install: DTB Tool source not found"
  echo -ne "$WHITE   Downloading from Github..."; kbelog -t "Install: Downloading from Github..."
  git clone https://github.com/KB-E/dtbtool resources/dtbtool &> /dev/null
  echo -e "$THEME$BLD Done$RATT"
else
  # If you didn't removed it, dtb is fine
  echo -e "$WHITE   DTB Tool source found"; kbelog -t "Install: DTB Tool source found"
fi

# So far, everything is now set up and KB-E is almost ready to run,
# display some info to the user about what's next
echo " "; kbelog -t "Install: Displaying user FirstRun information"
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
sleep 2
