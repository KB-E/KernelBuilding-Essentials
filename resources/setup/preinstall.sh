#!/bin/bash
# KB-E Pre-Installation Script
# By Artx <artx4dev@gmail.com>

# -------------------------------------
# Make some preparations before install
# -------------------------------------
# Set permissions
sudo chown -R $USER:users *
# Export current full path to KB-E
export kbe_path=$(pwd)
# Create KB-E Environment folders
folders=(devices logs source)
for i in "${folders[@]}"; do
  if [ ! -d $i ]; then
    mkdir $i
  fi
done; unset folders
# Load log script
source resources/log.sh
# Title
source resources/other/programtitle.sh
# Load Colors
source resources/other/colors.sh
# -------------------------
# All set, ready to install
#  -------------------------
