function checkfolders() {
  # Check environment folders and if one, some or all doesnt exist
  # create or restore it
  if [ "$1" != "--silent" ]; then
    echo " "
    echo -ne "$THEME$BLD - Checking Enviroment Folders... ";
  fi
  sleep 0.5
  folder () {
    if [ ! -d $CDF/$FD ]; then
      mkdir $CDF/$FD;
    fi
  }
  FD=source; folder
  FD=logs; folder
  FD=devices; folder
  unset FD
  if [ "$1" != "--silent" ]; then
    echo -e "$WHITE Done$RATT"
  fi
}
export -f checkfolders

