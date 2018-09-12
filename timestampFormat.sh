#!/bin/bash
# Nathan Oyama - Mon Sep 10 07:28:34 DST 2018
# 
# Checks and fixes the given timestamp,
# e.g. 01:23 -> 01:23:00 for roundDown
# e.g. 01:23 -> 01:23:59 for roundUp
# input $1: roundUp or roundDown
# input $2: timestamp (e.g. 0:00 01:01 2:00)

fillMinSec () {
    # Fills the minute or the second with 59 (roundUp) or 00 (roundDown)
    # input $1: minute (00-59) or the second (00-59)
    # input $2: roundUp or roundDown

    if   [[ "$1" == "roundUp"   ]]; then
        echo "59"
    elif [[ "$1" == "roundDown" ]]; then
        echo "00"
    else
        echo "Internal error occurred in the funciton roundUpDown()."
        exit 1
    fi
}

hour=$(echo "$2" | cut -d ':' -f 1)

if [[ $hour =~ ^[0-9]$ ]]; then
    hour=$(echo "0$hour")
fi
if   [[ "$2" =~ ^([01][0-9]|2[0-3])\:[0-5][0-9]\:[0-5][0-9]$ ]]; then
    min=$(echo "$2" | cut -d ':' -f 2)
    sec=$(echo "$2" | cut -d ':' -f 3)
elif [[ "$2" =~ ^([01][0-9]|2[0-3])\:[0-5][0-9]$ ]]; then
    min=$(echo "$2" | cut -d ':' -f 2)
    sec=$(fillMinSec "$1")
elif [[ "$2" =~ ^([01][0-9]|2[0-3])$ ]]; then
    min=$(fillMinSec "$1")
    sec=$(fillMinSec "$1")
fi

if [[ ! $hour =~ ^([01][0-9]|2[0-3])$ ]] \
    || [[ ! $min =~ ^[0-5][0-9]$ ]] || [[ ! $sec =~ ^[0-5][0-9]$ ]]; then
    echo "Invalid time. Please use \
me range between 00:00:00 and 23:59:59 and the timestamp format."
    exit 1
fi

echo "$hour:$min:$sec"

exit $?

