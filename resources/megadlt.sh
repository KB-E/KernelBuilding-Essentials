# MEGA AnyKernel Zip Download Facility
# By Artx/Stayn <jesusgabriel.91@gmail.com>

#Start
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
