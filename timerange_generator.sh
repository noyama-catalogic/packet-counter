#!/bin/bash
# Nathan Oyama - Fri Sep  7 03:27:45 DST 2018
# 
# Usage: 
# bash ./timerange_generator.sh <start_time HH:mm:ss> <end_time HH:mm:ss>
# 
# Example:
# bash ./timerange_generator.sh 01:50:18 03:02:05

START_HOUR=$(echo $1 | cut -d ':' -f 1)
START_MIN=$( echo $1 | cut -d ':' -f 2)
START_SEC=$( echo $1 | cut -d ':' -f 3)
END_HOUR=$(  echo $2 | cut -d ':' -f 1)
END_MIN=$(   echo $2 | cut -d ':' -f 2)
END_SEC=$(   echo $2 | cut -d ':' -f 3)

if   [ $START_HOUR -gt $END_HOUR ]; then
    echo "The time range ends after the midnight. Please use $2 23:59:59 and 00:00:00 $3."
    exit 1
elif [ $START_HOUR -lt $END_HOUR ]; then
    MULTI_HOUR=true
fi

if [ $START_MIN -lt $END_MIN ]; then
    MULTI_MIN=true
fi



if [ ! $MULTI_HOUR ] && [ ! $MULTI_MIN ]; then
    for i in `seq -w $START_SEC $END_SEC`; do
        echo "$START_HOUR:$START_MIN:$i"
    done
fi

multimin () {
    hour=$1
    start_min=$2
    start_sec=$3
    end_min=$4
    end_sec=$5

    for sec in `seq -w $start_sec 59`; do
        echo "$hour:$start_min:$sec"
    done
    for min in `seq -w $((start_min+1)) $end_min`; do
        if [ $min -lt $end_min ]; then
            for sec in `seq -w 00 59`; do
                echo "$hour:$min:$sec"
            done
        else
            for sec in `seq -w 00 $end_sec`; do
                echo "$hour:$end_min:$sec"
            done
        fi
    done
}

if [ ! $MULTI_HOUR ] && [   $MULTI_MIN ]; then
    multimin $START_HOUR $START_MIN $START_SEC $END_MIN $END_SEC
fi

if [   $MULTI_HOUR ]                    ; then
    multimin $START_HOUR $START_MIN $START_SEC 59 59
    for hour in `seq -w $((START_HOUR+1)) $END_HOUR`; do
        if [ $hour -lt $END_HOUR ]; then
            multimin $hour 00 00 59 59
        else
            multimin $hour 00 00 $END_MIN $END_SEC
        fi
    done
fi

exit $?

