sudo chmod 755 -R ./
sudo -R chown $USER:users *
# Main Script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Current Directory
CDF=$(pwd)

# Start
clear # Clear user UI
. resources/other/colors.sh
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
echo -e "              █████╗  ███████╗███████╗█████╗  ██╔██╗ ██║   ██║   ██║███████║██║     ███████╗        "
sleep 0.1
echo -e "              ██╔══╝  ╚════██║╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██╔══██║██║     ╚════██║        "
sleep 0.1
echo -e "              ███████╗███████║███████║███████╗██║ ╚████║   ██║   ██║██║  ██║███████╗███████║         "
sleep 0.1
echo -e "              ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝          "
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
if [ "$FRF" != "1" ]; then
echo -e "$GREEN - Kernel-Building Essentials it's ready!$RATT"
echo " "
fi
