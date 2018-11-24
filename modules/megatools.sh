#!/bin/bash

# MEGA Config file for New Releases Sharing
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# MEGA

# Identify the Module
MODULE_NAME=MegaTools
MODULE_VERSION=1.0
MODULE_DESCRIPTION="MegaTools, this module handles the config of megatools, download and uploading of files"
MODULE_PRIORITY=1 # Priority level is from 1 to 10

# MegaTools Log file
MEGALOG=$CDF/resources/logs/megalog.txt

# Upload the Kernel
megaupload () {
# Start
if [ "$NOUP" = 1 ]; then
  export NOUP=0
  echo -e "$RED - Upload is disabled, Run 'megacheck' Command to Re-Configure MEGA"
  return 1
fi
echo -ne "$GREEN$BLD"
echo -e "   _   _      _              _ "
echo -e "  | | | |_ __| |___  __ _ __| | "
echo -e "  | |_| | '_ \ / _ \/ _' / _' | "
echo -e "   \___/| .__/_\___/\__,_\__,_| "
echo -e "        |_|                    "
echo " "
echo -e "$GREEN$BLD - Initializing Kernel(s) upload...$RATT$WHITE"
export DATE=`date +%Y-%m-%d`
echo -e "   Kernel: $KERNELNAME; Variant: $VARIANT; Date: $DATE"
megacheck
echo " "
  # Try to remove the Kernel Installer and reload MegaTools Cache  
  if [ "$BLDTYPE" = "A" ]; then
    megarm /Root/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AROMA_"$DATE"_"$VARIANT"_KB-E"$KBV".zip &> /dev/null
    megals --reload &> /dev/null
  elif [ "$BLDTYPE" = "K" ]; then
    megarm /Root/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip &> /dev/null
    megals --reload &> /dev/null
  fi
  # --------
  # Upload the Kernel Installer(s)
  echo -e "$WHITE$BLD   Uploading Zip for $VARIANT to MEGA...$WHITE"
  if [ "$BLDTYPE" = "A" ]; then
    megaput $NZIPS/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AROMA_"$DATE"_"$VARIANT"_KB-E"$KBV".zip 2> $MEGALOG
    CHECKUPLOAD=$(grep -Ewo 'ERROR' $MEGALOG)
    if [ "$CHECKUPLOAD" = "ERROR" ]; then
      echo -e "$RED Error: File not found"
      # Report upload error to KB-E
      export UPLOADERROR=1
    else
      echo -e "$GREEN$BLD   Done$RATT"
    fi
  elif [ "$BLDTYPE" = "K" ]; then
    megaput $NZIPS/"$KERNELNAME"Kernel-v"$VERSION"-"$TARGETANDROID"-AnyKernel_"$DATE"_"$VARIANT"_KB-E"$KBV".zip 2> $MEGALOG
    CHECKUPLOAD=$(grep -Ewo 'ERROR' $MEGALOG)
    if [ "$CHECKUPLOAD" = "ERROR" ]; then
      echo -e "$RED Error: File not found"
      # Report upload error to KB-E
      export UPLOADERROR=1
    else
      echo -e "$GREEN$BLD   Done$RATT"
    fi
  fi
  echo -e "$RATT"
}

megacheck () {
echo " "
echo -e "$GREEN$BLD   Configuring MEGA...$RATT"
# Check Megatools
if ! [ -x "$(command -v megaput)" ]; then # Check if MEGATools is installed
  echo " "
  echo -e "$RED   MegaTools is not installed!$WHITE"
  export NOUP=1 # Export NoUpload, this will cancel megaupload function
                # because MEGATools isn't installed
  read -p "   Install MEGATools Now? (It'll take some time depending of your connection) [Y/N]: " IMT
  if [ "$IMT" = Y ] || [ "$IMT" = y ]; then
    installmega
  fi
else
  export NOUP=0
  echo -e "$WHITE   MegaTools found!"
  if [ ! -f ~/.megarc ]; then # If MEGATools is intalled but megarc is missing
                              # we'll create it (necessary for automatic upload)
    echo " "
    echo -e "$RED$BLD - File megarc is not configured yet! Please enter your email and password for uploads$WHITE"
    echo " "
    sudo echo "[Login]" > ~/.megarc
    read -p " * Email: " MEGAE; sudo echo "Username = $MEGAE" >> ~/.megarc
    read -sp " * Password: " MEGAP; sudo echo "Password = $MEGAP" >> ~/.megarc
    echo " "
    echo " "
    echo -e "$GREEN$BLD - MEGA Config Done!$RATT"
    # Unset Email and Password variables (Erase them)
    unset MEGAE
    unset MEGAP
    # ----------------------------------
    if [ -f ~/.megarc ]; then
      sudo chown $USER:users ~/.megarc
    fi
  fi
fi

# If user runs megacheck with --reconfigure flag (megacheck --reconfigure)
# then initialize megarc configuration again
if [ "$1" = "--reconfigure" ]; then
  export NOUP=0
  sudo chown $USER:users ~/.megarc
  echo " "
  echo -e "$GREEN$BLD   Re-Configuring megarc File...$WHITE"
  echo " "
  sudo echo "[Login]" > ~/.megarc
  read -p " * Email: " MEGAE; sudo echo "Username = $MEGAE" >> ~/.megarc
  read -sp " * Password: " MEGAP; sudo echo "Password = $MEGAP" >> ~/.megarc
  echo " "
  echo " "
  echo -e "$GREEN$BLD - MEGA Config Done!$RATT"
  # Unset Email and Password variables (Erase them)
  unset MEGAE
  unset MEGAP
  # ----------------------------------
fi
}

# Download a template from MEGA
megadlt () {
  # Check if MEGA is available
  megacheck
  # Clear some variables
  unset TFP; unset TN; unset DTA; unset ZIPERROR
  echo " "
  echo -e "$GREEN$BLD - You'll have to fill some data in order to download your template"
  echo -e "$WHITE   Please, enter the information correctly (the file must be .zip):"
  echo " "
  read -p " - Path to the folder in your MEGA that contains the Template: " TFP
  read -p " - File name (.zip): " TN
  # Combine path to the folder with file name to get full path
  MTP="$TFP/$TN"
  ZIPERROR=0
  echo -e "$LRED$BLD   Downloading specified template for: $VARIANT "
  # Start Downloading the template
  megaget $MTP --path $MAKT
  # Check if the process was done sucessfully
  if [ ! -f $MAKT/"$TN" ]; then # In the template failed promt the user
                                    # to try again or use local template
    echo -e "$RED   Error downloading $VARIANT Base Zip, check the path$WHITE"
    read -p " - Try again? [Y/N]: " DTA
    export ZIPERROR=1
    echo " "
  fi


# Restart the process if user wants to try again
if [ "$DTA" = y ] || [ "$DTA" = y ]; then
    megadlt
    return 1
fi

if [ "$ZIPERROR" = 1 ]; then
  # If it was impossible to get the template finish this script
  return 1
fi

# Extract the files inside ./out/mega_aktemplate/
cd $MAKT
echo -e "$GREEN$BLD - Extracting $TN files..." 
unzip $TN &> /dev/null
rm $TN
echo -e "$WHITE   Done"
cd $CDF
}
