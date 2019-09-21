#!/bin/bash

# Updater Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

if grep -q "# Load KB-E Function and Path" ~/.bashrc; then
  # Remove old code from ~/.bashrc
  sudo sed -i '/# Load KB-E Function and Path/d' ~/.bashrc
  sudo sed -i '/CDF=/d' ~/.bashrc
  sudo sed -i '/colors.sh/d' ~/.bashrc
  sudo sed -i '/core.sh/d' ~/.bashrc
  sudo sed -i '/log.sh/d' ~/.bashrc
  sudo sed -i "/complete -W 'start upgrade' kbe/d" ~/.bashrc
  sudo sed -i "/complete -W 'start update' kbe/d" ~/.bashrc
fi

# Check if user doesn't have the build DTB
# manually setting stored in his devices
for f in $CDF/devices/*/*/*.data
do
  if ! grep -q "BDTB" $f; then
    echo " "; echo "DTB Building data missing in $(basename $f)"
    kernel_name="$(basename $f | cut -d '.' -f 1)"
    echo -n "Do you want to manually build DTB for $kernel_name? [Y/N]: "
    read apply_setting;
    if [ "$apply_setting" = "y" ] || [ "$apply_setting" = "Y" ]; then
      echo "BDTB=1" >> $f
    else
      echo "export BDTB=0" >> $f
    fi
    echo "Done..!"
  fi
done
