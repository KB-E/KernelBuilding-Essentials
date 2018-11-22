#!/bin/bash

# Program tools functions
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Install Building Tools
installtools () {
  echo " "
  sudo apt-get update
  sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev device-tree-compiler ccache
  echo " "
}

# Load auto.sh function into .bashrc
writeprogramconfig () {
  echo " "
  echo -ne "$GREEN$BLD - Writting KB-E Config in ~/.bashrc...$WHITE"
  sudo sed -i '/# Load auto.sh function and path/d' ~/.bashrc
  sudo sed -i '/CDF=/d' ~/.bashrc
  sudo sed -i '/resources/other/colors.sh/d' ~/.bashrc
  sudo sed -i '/auto.sh/d' ~/.bashrc
  echo "# Load auto.sh function and path" >> ~/.bashrc
  echo "CDF=$CDF" >> ~/.bashrc
  echo ". $CDF/resources/other/colors.sh" >> ~/.bashrc
  echo ". $CDF/auto.sh" >> ~/.bashrc
  . $CDF/auto.sh
  echo -e " Done"
  echo " "
}

# Install MEGATools used by this program
installmega () {
  # Check if MEGATools is already installed
  if [ -x "$(command -v megaput)" ]; then
    echo " "
    echo -e "$WHITE   MEGATools is already installed, exiting..."
    echo " "
    return 1
  fi
  echo " "
  echo -e "$GREEN$BLD   Installing MEGATools...$WHITE"
  # Make temp folder for installation
  mkdir megatemp
  cd megatemp
  wget https://megatools.megous.com/builds/megatools-1.9.98.tar.gz
  tar -xzf megatools-1.9.98.tar.gz
  cd megatools-1.9.98
  # Install dependencies
  sudo apt-get install libcurl4-gnutls-dev libglib2.0-dev asciidoc fop
  ./configure
  make
  sudo make install
  cd ../../
  # Clean temp folder
  rm -rf megatemp
  echo -e "$WHITE   Done"
  # Configure megarc
  megacheck
  unset NOUP
}

# AnyKernel extract
templatesconfig () {
  cp -rf $AKTF/* $AKT
  echo -e "$GREEN$BLD   AnyKernel Extract Done"
  export AKED=1
}
