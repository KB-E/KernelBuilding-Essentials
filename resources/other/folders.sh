#!/bin/bash

# Generate Enviroment Necessary Folders
# By Artx/Stayn <jesusgabriel.91@gmail.com>

checkfolders () {
  echo " "
  echo -e "$GREEN$BLD - Checking Enviroment Folders..."
  sleep 0.5
  folder () {
    if [ ! -d $CDF/$FD ]; then
      mkdir $CDF/$FD
      echo -e "$WHITE   Generated $FD folder$RATT"
    fi
  }
  FD=out; folder
  FD=out/zImagesNew; folder
  FD=out/zImages; folder
  FD=out/aktemplate; folder
  FD=out/newzips; folder
  FD=out/dt; folder
  FD=source; folder
  FD=templates; folder
  FD=resources/logs; folder
  FD=resources/devices; folder
  #echo " "
  echo -e "$GREEN$BLD   Done$RATT"
  echo " "
}

# Done here
echo -e "$WHITE * Function 'checkfolders' Loaded$RATT"
