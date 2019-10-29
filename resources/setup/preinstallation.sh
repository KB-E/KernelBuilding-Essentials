#!/bin/bash
# Pre-Installation Script
# By Artx <artx4dev@gmail.com>

# Display Disclaimer
disclaimer=$(cat resources/setup/disclaimer.txt); echo " "; echo $disclaimer; unset disclaimer
echo " "; read -p " - Do you agree the above disclaimer and continue? [Y/N]: " DAG
echo " " 
# Exit the pre-installation with variable "agreed_disclaimer" set to false
# for the core script if user doesn't like it >:(
if [ "$DAG" != "y" ] && [ "$DAG" != "Y" ]; then
  export agreed_disclaimer=false; unset DAG; return 1
fi; unset DAG
read -p "   Thanks, good luck with your builds! Press enter to continue..."; echo " "
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
# -------------------------
