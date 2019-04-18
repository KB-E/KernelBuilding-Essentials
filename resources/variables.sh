#!/bin/bash

# All Paths used for the Program facility
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Local Folders Paths
export ZI=$CDF/"out/Images/" # Last Built zImages
export DT=$CDF/"out/dt/" # New Device Tree Images for each variants (dtb)

# Variants file
export VF=$OTHERF/variants.sh

# Module List
export MLIST=$CDF/resources/other/modulelist.txt

# Core Devices
export CORED=$CDF/resources/core-devices

# Resources folder
export SRCF=$CDF/"resources/"

# Log output folder
export LOGF=$CDF/"resources/logs/" # Build Kernel and dt.img logs comes here

# dtbToolLineage
export DTB=$CDF/"resources/dtb/dtbtool"

# Others folder
export OTHERF=$CDF/"resources/other/" # First run file, other paths variables, etc...

# Help fle path
export HFP=$CDF/README.md
