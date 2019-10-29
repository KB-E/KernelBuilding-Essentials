#!/bin/bash
# Log Library for general purposes
# By Artx/Stayn <artx4dev@gmail.com>

# Main Function
# Usage: userlog <flag> <function/text> <filepath> 
function userlog() {
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
    # "-f" is to check a function
    # "-t" is to write text (both cases automatically append the date)
    case $1 in
        (-f|-t) ;; # OK
        (*) echo -e "Error: '$1' flag not recognized"; return 1;;
    esac

    # A function needs to be specified when using "-f" flag
    if [ "$1" = "-f" ] && [ "$2" = "" ]; then
        echo "Error: function not specified"
        return 1
    fi

    # Some text needs to be written when using "-t" flag
    if [ "$1" = "-t" ] && [ "$2" = "" ]; then
        echo "Error: text needs to be written"
        return 1
    fi

    # Check filepath where log is written
    FILEPATH=$3
    if [ "$FILEPATH" != "" ]; then
        DIR=$(dirname "${FILEPATH}")
    fi
    if [ "$3" = "" ]; then
        echo "Error: filepath is empty"
        return 1
    elif [ ! -d "$DIR" ]; then
        echo "Error: filepath directory doesnt exist"
        return 1
    fi;

    # -------------------
    # Now the real stuff
    # -------------------
    # Create the log file
    if [ ! -f "$3" ]; then
        touch "$3"
    fi

    # For "-f" flag
    if [ "$1" = "-f" ]; then
        if ! type "$2" &> /dev/null; then
            echo "[E]$(date) | $2: Command not found" >> $3
        else
            echo "[I]$(date) | $2: Loaded, command found" >> $3
        fi
    fi

    # For "-t" flag
    if [ "$1" = "-t" ]; then
        echo "[I]$(date) | $2" >> $3
    fi
}
export -f userlog

function kbelog() {
    # ------------
    # Checks
    # ------------
    # A Flag must be specified
    # "-f" is to check a function
    # "-t" is to write text (both cases automatically append the date)
    case $1 in
        (-f|-t) ;; # OK
        (*) echo -e "Error: '$1' flag not recognized"; return 1;;
    esac

    # A function needs to be specified when using "-f" flag
    if [ "$1" = "-f" ] && [ "$2" = "" ]; then
        echo "Error: function not specified"
        return 1
    fi

    # Some text needs to be written when using "-t" flag
    if [ "$1" = "-t" ] && [ "$2" = "" ]; then
        echo "Error: text needs to be written"
        return 1
    fi

    # -------------------
    # Now the real stuff
    # -------------------
    kbelog_path=$kbe_path/logs/kbe.log
    # Create the log file
    if [ ! -f "$kbelog_path" ]; then
        touch "$kbelog_path"
    fi

    # For "-f" flag
    if [ "$1" = "-f" ]; then
        if ! type "$2" &> /dev/null; then
            echo "[E]$(date) | $2: Command not found" >> $kbelog_path
        else
            echo "[I]$(date) | $2: Loaded, command found" >> $kbelog_path
        fi
    fi

    # For "-t" flag
    if [ "$1" = "-t" ]; then
        echo "[I]$(date) | $2" >> $kbelog_path
    fi
}
export -f kbelog
