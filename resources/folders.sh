# Generate Enviroment Necessary Folders
# By Artx/Stayn <jesusgabriel.91@gmail.com>

checkfolders () {
  echo " "
  echo -e "$GREEN$BLD - Checking Enviroment Folders..."
  sleep 0.5
  folder () {
    if [ ! -d $FD ]; then
      mkdir $FD
      echo -e "$WHITE   Generated $FD folder$RATT"
    fi
  }
  FD=out; folder
  FD=out/zImagesNew; folder
  FD=out/zImages; folder
  FD=out/zips; folder
  FD=out/zips2; folder
  FD=out/temp; folder
  FD=out/temp2; folder
  FD=out/aromafiles; folder
  FD=out/anykernelfiles; folder
  FD=out/anykernelfiles/ramdisk; folder
  FD=out/newzips; folder
  FD=out/dt; folder
  FD=source; folder
  FD=crosscompiler; folder
  FD=resources/logs; folder
  #echo " "
  echo -e "$GREEN$BLD   Done$RATT"
  echo " "
}

# Done here
echo -e "$WHITE * Function 'checkfolders' Loaded$RATT"
