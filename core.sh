# Main Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

if [ ! -f ./resources/other/firstrun ]; then
  echo " "
  echo -e " - Disclaimer: "
  echo " "
  echo -e "   This Software will ask for sudo to download the required programs"
  echo -e "   and tools, also, to chmod and chown neccesary files for the"
  echo -e "   correct functioning of all the code, I'm not responsable if this"
  echo -e "   program breaks your PC (which it shouldn't be able). We'll now"
  echo -e "   proceed to the first run of this program after your authorization..."
  echo " "
  read -p " - Do you agree the above disclaimer and continue? [Y/N]: " DAG
  echo " "
  if [ "$DAG" != "y" ] && [ "$DAG" != "Y" ]; then
    return 1
  fi
  read -p "   Thanks and good luck with your builds! Press enter to continue..."
  echo " "
fi

sudo chmod 755 -R ./
sudo chown -R $USER:users *

# Load Colors
. resources/other/colors.sh

# If 'firstrun' file is missing perform a clean of this program environment
if [ ! -f ./resources/other/firstrun ]; then
  echo -e "$GREEN$BLD - Perfoming a Cleaning...$WHITE"
  rm ./defaultsettings.sh
  cp ./resources/other/defaultsettings.sh ./
  if [ -d ./resources/crosscompiler/ ]; then
    rm -rf ./resources/crosscompiler/
  fi
  if [ -d ./out/ ]; then
    rm -rf ./out/
  fi
  if [ -f ./resources/logs/* ]; then
    rm ./resources/logs/*
  fi
  echo -e "   Done"
sleep 1.5
fi

# Current Directory
CDF=$(pwd)

# Start
# KB-E Version
KBV=1.0
clear # Clear user UI
unset CWK

# Tittle with style
echo -e "$WHITE"
echo -e "██╗  ██╗███████╗██████╗ ███╗   ██╗███████╗██╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ██╗███╗   ██╗ ██████╗"
sleep 0.1
echo -e "██║ ██╔╝██╔════╝██╔══██╗████╗  ██║██╔════╝██║     ██╔══██╗██║   ██║██║██║     ██╔══██╗██║████╗  ██║██╔════╝"
sleep 0.1
echo -e "█████╔╝ █████╗  ██████╔╝██╔██╗ ██║█████╗  ██║     ██████╔╝██║   ██║██║██║     ██║  ██║██║██╔██╗ ██║██║  ███╗"
sleep 0.1
echo -e "██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╗██║██╔══╝  ██║     ██╔══██╗██║   ██║██║██║     ██║  ██║██║██║╚██╗██║██║   ██║"
sleep 0.1
echo -e "██║  ██╗███████╗██║  ██║██║ ╚████║███████╗███████╗██████╔╝╚██████╔╝██║███████╗██████╔╝██║██║ ╚████║╚██████╔╝"
sleep 0.1
echo -e "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝ "
sleep 0.1
echo -e "                                                                                                        "
sleep 0.1
echo -e "              ███████╗███████╗███████╗███████╗███╗   ██╗████████╗██╗ █████╗ ██╗     ███████╗         "
sleep 0.1
echo -e "              ██╔════╝██╔════╝██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║██╔══██╗██║     ██╔════╝        "
sleep 0.1
echo -e "              █████╗  ███████╗███████╗█████╗  ██╔██╗ ██║   ██║   ██║███████║██║     ███████╗    KB-E v$KBV"
sleep 0.1
echo -e "              ██╔══╝  ╚════██║╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██╔══██║██║     ╚════██║     By Artx"
sleep 0.1
echo -e "              ███████╗███████║███████║███████╗██║ ╚████║   ██║   ██║██║  ██║███████╗███████║   "
sleep 0.1
echo -e "              ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝    "
# Gay tittle end
echo " "
echo -e "$GREEN$BLD  - Initializing...$RATT"
echo " "
sleep 1 # your cpu will burn in hell, take a breath of this heavy tittle... jk

# Initialize KB-E Resources and Functions
#. resources/other/colors.sh
. resources/other/folders.sh
. resources/paths.sh
. resources/buildtools.sh
. resources/setuptools.sh
. resources/megaconfig.sh
. resources/megadlt.sh
. resources/other/help.sh
. scripts/buildkernel.sh
. scripts/makedtb.sh
. scripts/makeanykernel.sh
#. scripts/makearoma.sh
. scripts/upload.sh
. defaultsettings.sh
if [ $AUSETTINGS = 1 ]; then
  . runsettings.sh
fi

if [ "$CWK" = "n" ] && [ "$CWK" = "N" ]; then
  return 1
fi
echo " "

# Main command, you'll tell here to the program what to do
essentials () {
  # If user defined --kernel flag, Build kernel
  if [ "$1" = "--kernel" ] || [ "$2" = "--kernel" ] || [ "$3" = "--kernel" ] || [ "$4" = "--kernel" ]; then
    if [ $KDEBUG = 1 ]; then
      buildkernel_debug
    else
      buildkernel
    fi
  fi

  # If user defined --dtb flag, Build dtb (dt.img (Device Tree Image))
  if [ "$1" = "--dtb" ] || [ "$2" = "--dtb" ] || [ "$3" = "--dtb" ] || [ "$4" = "--dtb" ]; then
    build_dtb
  fi

  # If user defined --make_anykernel flag, Build AnyKernel Installer
  if [ "$1" = "--anykernel" ] || [ "$2" = "--anykernel" ] || [ "$3" = "--anykernel" ] || [ "$4" = "--anykernel" ]; then
    make_anykernel
  fi

  # If user defined --upload flag, Upload the last built Installer
  if [ "$1" = "--upload" ] || [ "$2" = "--upload" ] || [ "$3" = "--upload" ] || [ "$4" = "--upload" ]; then
    megaupload
  fi

  # If user defined --all flag, do everything automatically
  if [ "$1" = "--all" ]; then
    if [ $KDEBUG = 1 ]; then
      buildkernel_debug
    else
      buildkernel
    fi
    build_dtb
    make_anykernel
    megaupload
  fi
}

# Done
if [ "$RD" = "1" ]; then
  echo -e "$GREEN - Kernel-Building Essentials it's ready!$RATT"
  echo " "
else
  echo -e "$RED - Session cancelled by user$RATT"
  echo " "
fi

