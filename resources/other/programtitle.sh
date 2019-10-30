#!/bin/bash

# KB-E Title :)
function title() {
  echo -e "$WHITE"
  
  echo -e "     ██$THEME$BLD╗$WHITE  ██$THEME$BLD╗$WHITE██████$THEME$BLD╗$WHITE       ███████$THEME$BLD╗$WHITE"
  echo -e "     ██$THEME$BLD║$WHITE ██$THEME$BLD╔╝$WHITE██$THEME$BLD╔══$WHITE██$THEME$BLD╗$WHITE      ██$THEME$BLD╔════╝$WHITE"
  echo -e "     █████$THEME$BLD╔╝$WHITE ██████$THEME$BLD╔╝$WHITE█████$THEME$BLD╗$WHITE█████$THEME$BLD╗$WHITE  "
  echo -e "     ██$THEME$BLD╔═$WHITE██$THEME$BLD╗$WHITE ██$THEME$BLD╔══$WHITE██$THEME$BLD╗╚════╝$WHITE██$THEME$BLD╔══╝$WHITE  "
  echo -e "     ██$THEME$BLD║$WHITE  ██$THEME$BLD╗$WHITE██████$THEME$BLD╔╝$WHITE      ███████$THEME$BLD╗$WHITE"
  echo -e "     $THEME$BLD╚═╝  ╚═╝╚═════╝       ╚══════╝"
  echo -e "       KernelBuilding Essentials   "
  echo -e "           $THEME$BLD-$WHITE v$VERSION by: Artx $THEME$BLD-$WHITE       "
  echo " "
}
export -f title; kbelog -f title
