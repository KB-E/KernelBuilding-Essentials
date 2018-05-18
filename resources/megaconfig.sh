# MEGA Config file for New Releases Sharing
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# MEGA

megacheck () {
echo -e "$GREEN - Configuring MEGA...$RATT"
# Check Megatools
if ! [ -x "$(command -v megaput)" ]; then # Check if MEGATools is installed
  echo -e "$RED - MegaTools is not installed!$WHITE"  
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
                              # we'll create it (necessary for automatic uploads)
    echo " "
    echo -e "$LRED - File megarc is not configured yet! Please enter your email and password for uploads$WHITE"
    echo ~/.megarc > "[Login]"
    read -p " * Email: " MEGAE; echo ~/.megarc >> "Username = $MEGAE"
    read -sp " * Password: " MEGAP; echo ~/.megarc >> "Password = $MEGAP"
    echo " "
    echo " "
    echo -e "$GREEN - MEGA Config Done!$RATT"
    # Unset Email and Password variables (Erase them)
    unset MEGAE
    unset MEGAP
    # ----------------------------------
  fi
fi

# If user runs megacheck with --reconfigure flag (megacheck --reconfigure)
# then initialize megarc configuration again
if [ "$1" = "--reconfigure" ]; then
  export NOUP=0
  echo " "
  echo -e "$GREEN - Re-Configuring megarc File...$WHITE"
  echo " "
  echo ~/.megarc > "[Login]"
  read -p " * Email: " MEGAE; echo ~/.megarc >> "Username = $MEGAE"
  read -sp " * Password: " MEGAP; echo ~/.megarc >> "Password = $MEGAP"
  echo " "
  echo " "
  echo -e "$GREEN - MEGA Config Done!$RATT"
  # Unset Email and Password variables (Erase them)
  unset MEGAE
  unset MEGAP
  # ----------------------------------
fi
}

# Done here
echo -e "$WHITE * Function 'megacheck' Loaded$RATT"