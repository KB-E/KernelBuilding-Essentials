#!/bin/bash
# Log Library for general purposes
# By Artx/Stayn <artx4dev@gmail.com>

# Main Function
# Usage: log <flag> <function/text> <filepath> 
function log() {
    # User Information
    if [ "$1" = "" ] && [ "$2" = "" ] && [ "$3" = "" ]; then
        echo "[Log Script] Usage:     log -f <function> <filepath> (Test a function)"
        echo "                        log -t <text> <filepath> (Write text to a file)"
        echo " "
        echo "These functions writes text to a specified file (filepath)"
        echo "If the file doesn't exist, it'll be generated"  
        return 1
    fi

    # ------------
    # Checks
    # ------------

    # A Flag must be specified
    case $1 in
        (-f|-t) ;; # OK
        (*) echo -e "Error: '$1' flag not recognized"; return 1;;
    esac

    # Function needs to be specified 
    if [ "$1" = "-f" ] && [ "$2" = "" ]; then
        echo "Error: function not specified"
        return 1
    fi

    # Text needs to be written
    if [ "$1" = "-t" ] && [ "$2" = "" ]; then
        echo "Error: text needs to be written"
        return 1
    fi

    # Test filepath
    var=$3
    if [ "$var" != "" ]; then
        dir=$(dirname "${var}")
    fi
    if [ "$3" = "" ]; then
        echo "Error: filepath is empty"
        return 1
    elif [ ! -d "$dir" ]; then
        echo "Error: filepath directory doesnt exist"
        return 1
    fi

    # -------------------
    # Now the real stuff
    # -------------------

    # Create the file
    if [ ! -f "$3" ]; then
        touch "$3"
    fi

    # "-f" Flag
    if [ "$1" = "-f" ]; then
        if ! type "$2" &> /dev/null; then
            echo "[E]$(date) | $2: Command not found" >> $3
        else
            echo "[I]$(date) | $2: Loaded, command found" >> $3
        fi
    fi

    # "-t" Flag
    if [ "$1" = "-t" ]; then
        echo "[I]$(date) | $2" >> $3
    fi

}
export -f log
