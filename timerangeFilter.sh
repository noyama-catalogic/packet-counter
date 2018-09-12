#!/bin/bash
# Nathan Oyama - Mon Sep 10 07:28:34 DST 2018
# 
# Usage: 
# bash ./timerangeFilter.sh <source_file> <start_time> <end_time>
# 
# where each line of <source_file> MUST starts with a timestmap
# in HH:mm:ss and <start_time> and <end_time> are in either
# H:mm:ss or HH:mm:ss.
# 
# Example:
# bash ./timerangeFilter.sh tcpdumpLog.dat 21:26 21:28 
# 
# Restriction:
# The target log must have a timestamp (HH:mm:ss) at the beginning of 
# each line. Use "cut" to trim excessive characters before timestamps in 
# the target file if needed.
# This script does not support a log that includes a record with 
# mulitple lines.
# The target log file does not need to be ordered by the timestamps.
# 
# Output:
# All the lines with the timestamps within the given timerange.
# It is ordered by the timestamp.

SOURCE_FILE="$1"
START_TIME="$2"
END_TIME="$3"

grep "^\([01][0-9]\|2[0-3]\):[0-5][0-9]:[0-5][0-9]" $SOURCE_FILE | sort \
    > ./${SOURCE_FILE}_sorted.tmp
cut -c 1-8 ./${SOURCE_FILE}_sorted.tmp | sed "s/://g" \
    > ./${SOURCE_FILE}_sorted_timestamps.tmp

START_LN=$(awk -v start_time_digit=`echo $START_TIME | tr -d ':'` \
'$1 >= start_time_digit {print NR ; exit}' \
./${SOURCE_FILE}_sorted_timestamps.tmp)

END_LN=$(tail -n +$START_LN ./${SOURCE_FILE}_sorted_timestamps.tmp |
awk -v end_time_digit=`echo $END_TIME | tr -d ':'` \
'$1 > end_time_digit { print NR - 1 ; exit}')

sed -n "${START_LN},${END_LN}p" ${SOURCE_FILE}_sorted.tmp

rm ${SOURCE_FILE}_sorted.tmp
rm ${SOURCE_FILE}_sorted_timestamps.tmp

exit 0

