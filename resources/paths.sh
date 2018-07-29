#!/bin/bash

# All Paths used for the Program facility
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Local Folders Paths
ZIN=$CDF/"out/zImagesNew/" # Recently built zImages
ZI=$CDF/"out/zImages/" # Last Built zImages
NZIPS=$CDF/"out/newzips/" # New Zips built output folder (AROMA/AnyKernel/Others)
AKT=$CDF/"out/aktemplate/" # AnyKernel source will be extracted here and used has template
DT=$CDF/"out/dt/" # New Device Tree Images for each variants (dtb)

# Resources folder
SRCF=$CDF/"resources/"

# Local Templates folder
AKTF=$CDF/"resources/localtemplates/anykernel/"
ATF=$CDF/"resources/localtemplates/aroma/"

# User Templates folder
UTF=$CDF/"templates"

# Log output folder
LOGF=$CDF/"resources/logs/" # Build Kernel and dt.img logs comes here

# dtbToolLineage
DTB=$CDF/"resources/dtb/dtbToolLineage"

# Others folder
OTHERF=$CDF/"resources/other/" # First run file, other paths variables, etc...

# Help fle path
HFP=$CDF/README.md

# All set
echo -e "$GREEN$BLD * Loaded Program Paths$RATT"
