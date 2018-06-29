# Check Building Tools
# By Artx/Stayn <jesusgabriel.91@gmail.com>

checkenvironment () {
echo " "
echo -e "$LCYAN$BLD - Checking Evironment..."
echo " "
# CROSS_COMPILER
if [ ! -f "$CROSSCOMPILE"gcc ]; then
  echo -e "$RED$BLD   Cross Compiler not found ($CROSSCOMPILE) "
  export CERROR=1 # Tell to the program that the CrossCompiler isn't availible
else
  echo -e "$WHITE   Cross Compiler Found!"
  export CERROR=0 # Initialize CrossCompilerERROR Variable
fi

# Check DTB tool
if [ ! -f $DTB ]; then # Check local dtbTool
  echo -e "$RED$BLD   DTB Tool not found, continuing without it...$RATT$WHITE"
  NODTB=1
else
  # If you didn't removed it, dtb is fine
  echo -e "$WHITE   DTB Tool found (It'll be generated if it is enabled by user)"
fi

# Check Zip Tool
if ! [ -x "$(command -v zip)" ]; then # C'mon, just install it with:
                                      # sudo apt-get install zip
  echo -e "$RED$BLD   Zip is not installed, Kernel installer Zip will not be build!$WHITE"
  echo " "
  read -p "   Install Zip Tool? [y/n]: " INSZIP
  if [ $INSZIP = Y ] || [ $INSZIP = y ]; then
    sudo apt-get install zip
  else
  echo " "
  export NOBZ=1 # Tell the Zip building function to cancel the opetarion
                # because Zip tool is 100% necessary
  fi
else
  export NOBZ=0 # Well, you had it, nice!
  echo -e "   Zip Tool Found! $RATT"
  echo " "
fi

echo -e "$LCYAN$BLD   Done$RATT"
echo " "

}

# Done
echo -e "$WHITE * Function 'checkenvironment' Loaded$RATT"
