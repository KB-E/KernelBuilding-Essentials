# All Paths used for the Program facility
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Local Folders Paths
ZIN=$CDF/"out/zImagesNew/" # Recently built zImages
ZI=$CDF/"out/zImages/" # Last Built zImages
TMP=$CDF/"out/temp/" # Temp folder (Used for unzipping AROMA files)
TMP2=$CDF/"out/temp2/" # Temp folder 2 (Used for unzipping AnyKernel and other files)
NZIPS=$CDF/"out/newzips/" # New Zips built output folder (AROMA/AnyKernel/Others)
ZIPS=$CDF/"out/aroma/" # Base Zips for new kernel installer builds (AROMA)
ZIPS2=$CDF/"out/anykernel/" # Base Zips for new kernel installer builds (AnyKernel)
FILES=$CDF/"out/aromafiles/" # Files to be updated in the new AROMA Installer Build
FILES2=$CDF/"out/anykernelfiles/" # Files to be updated in the new AnyKernel Installer Build
RAMDISKF=$CDF/"out/anykernelfiles/ramdisk/" # Ramdisk files folder,
                                            # all files here will be added to anykernel zip
DT=$CDF/"out/dt/" # New Device Tree Images for each variants (dtb)

# Resources folder
SRCF=$CDF/"resources/"

# Templates folder
AKTF=$CDF/"resources/templates/anykernel/"
ATF=$CDF/"resources/templates/aroma/"

# Log output folder
LOGF=$CDF/"resources/logs/" # Build Kernel and dt.img logs comes here

# dtbToolLineage
DTB=$CDF/"resources/dtb/dtbToolLineage"

# Others folder
OTHERF=$CDF/"resources/other/" # First run file, other paths variables, etc...

# Help fle path
HFP=$CDF/help.txt

# All set
echo -e "$GREEN$BLD * Loaded Program Paths$RATT"
