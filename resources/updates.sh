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
