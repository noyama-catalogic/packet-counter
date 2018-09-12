#!/bin/bash
# Nathan Oyama - Fri Sep  7 03:38:11 DST 2018
# 
# Usage: 
# bash ./packetCounter.sh <file> <IP> <start time> <end time>
# <file>       A packet record file you get by running the following 
#   command on the target device:
#   $ tcpdump -i any -nnq > ./$(hostname)_$(env TZ=UTC date +%F_%H%M)UTC.dat
# <IP>         The IP address of the target device.
# 
# Example:
# bash ./packetCounter.sh target_pc_2018-09-07_0556UTC.dat \
#    10.20.30.40 01:50 02:05

FILE=$1
IP=$2
START_TIME=$3
END_TIME=$4

START_TIME=`bash timestampFormat.sh "roundDown" $START_TIME`
END_TIME=`  bash timestampFormat.sh "roundUp"     $END_TIME`

START_TIME_D=$(echo $START_TIME | tr -d ':')
END_TIME_D=$(  echo   $END_TIME | tr -d ':')

if [[ $START_TIME_D -gt $END_TIME_D ]]; then
    echo "The time range goes across midnight. Please split the target file \
at midnight and run this script multiple times."
    exit 1
fi

FILENAME="$(echo $FILE | sed "s/.dat$//")_${START_TIME_D}_${END_TIME_D}"

bash ./timerange_filter.sh $FILE $START_TIME $END_TIME > ./${FILE}_filtered.tmp

csv_formatter () {
    sourceFile=$1
    awk -F '[. ]' \
        '{print $1","$4"."$5"."$6"."$7","$8",>,"$10"."$11"."$12"."$13","$14}' \
        $sourceFile | sort | uniq -c | sed "s/^ *//g" | tr ' ' ',' \
        | sed "s/:$//g" >  ./${sourceFile}_main.tmp
    awk -F ',' '{ \
        knownPorts["2049"]; \
        ( $4 < $7 || $4 in knownPorts || ! ($7 in knownPorts) ) \
        ? min = $4 : min = $7; print min}' \
        ./${sourceFile}_main.tmp > ./${sourceFile}_port.tmp

    paste -d ',' ./${sourceFile}_main.tmp ./${sourceFile}_port.tmp

    rm ./${sourceFile}_main.tmp
    rm ./${sourceFile}_port.tmp
}

# Incoming packets received at $IP
echo "# of packets,Time,Source,Source Port,>,Destination,Destionation Port,\
    Port" > ./${FILENAME}_incoming.csv

grep " IP .* > $IP.*" ${FILE}_filtered.tmp > ./${FILE}_filtered_incoming.tmp
csv_formatter ./${FILE}_filtered_incoming.tmp >> ./${FILENAME}_incoming.csv

# Outgoing packets submitted form $IP
echo "# of packets,Time,Source,Source Port,>,Destination,Destionation Port,\
    Port" > ./${FILENAME}_outgoing.csv

grep " IP $IP.* > .*" ${FILE}_filtered.tmp > ./${FILE}_filtered_outgoing.tmp
csv_formatter ./${FILE}_filtered_outgoing.tmp >> ./${FILENAME}_outgoing.csv

rm ./${FILE}_filtered.tmp
rm ./${FILE}_filtered_incoming.tmp
rm ./${FILE}_filtered_outgoing.tmp

exit $?

