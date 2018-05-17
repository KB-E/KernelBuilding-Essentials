# Download all Tools needed by this whole program
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Install Building Tools
installtools () {
  echo " "
  sudo apt-get update
  sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache
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
  echo -e "$GREEN - Installing MEGATools..."
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
  cd ../
  # Clean temp folder
  rm -rf megatemp
  echo -e "$WHITE   Done"
  # Configure megarc
  megacheck
  unset NOUP
}

downloadcc () {
  echo " "
  echo -e "$GREEN - Downloading the $ARCH CrossCompiler... $WHITE"
  if [ "$ARCH" = arm64 ]; then
    git clone https://github.com/KB-E/gcc-arm64 $CDF/resources/crosscompiler/arm64/
    echo -e "$WHITE   Done"
  fi
  if [ "$ARCH" = arm ]; then
    git clone https://github.com/KB-E/gcc-arm $CDF/resources/crosscompiler/arm/
    echo -e "$WHITE   Done"
  fi
}
