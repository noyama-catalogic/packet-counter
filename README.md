# packet-counter
A Pakcet Counter for tcpdump

## System Requirement
### Target Device
* tcpdump

### Device that runs Packet Counter
* Bash (v4+)
* AWK
* UNIX environment

### Spreadsheet application (optional)
The script returns the packet analysis result in two CSV files: (1) incoming packets and (2) outgoing packets. You can use any CSV viewers, but it is advised to use a spreadsheet application that supports easy-to-use filters such as
* Microsoft Excel
* LibreOffice

## Usage
Run the following script on the target device:
```bash
$ tcpdump -i any -nnq > ./$(hostname)_$(env TZ=UTC date +%F_%H%M)UTC.dat
```
To end capturing packets, press [Ctrl] + [c].

Run the following command on the dcevice you want to capture packets.
```bash
$ bash ./packetCounter.sh <file> <IP> <start time> <end time>
```
* `<file>`: A packet record file you get by running the following command on the target device:
```bash
$ tcpdump -i any -nnq > ./$(hostname)_$(env TZ=UTC date +%F_%H%M)UTC.dat
```
* `<IP>`: The IP address of the target device. E.g. 10.20.30.40.
* `<start time>`: The start time you want to retrieve. The output will start from the first records with the timestamps which is the same or larger than the given start time. Use the <HH>, <HH:mm> or <HH:mm:ss> format. E.g. 09:50.
* `<end time>`: The end time you want to retrieve. The output will end at one line before the first record whose timestamp is one second ahead of the given end time. The Use the <HH>, <HH:mm> or <HH:mm:ss> format. E.g. 12:34:56.

### Example:
Consider you logged into your computer 10.20.30.40, ran the tcpdump command and got the packet record file _target_pc_2018-09-07_0556UTC.dat_.  If you want to retrieve the packet count record with the timestamps between 01:50 and 02:05, run the following command:
```bash
bash ./packetCounter.sh target_pc_2018-09-07_0556UTC.dat 10.20.30.40 01:50 02:05
```


## Q&A
### Tips
**Question 1.** I captured packets over midnight: from 23:00 through 01:00 on the next day.  But this script doesn't support a log file with multiple dates.  What should I do?

_Ans._ Split your log files using text processing tools as needed.  For example, if you have a UNIX environment with you, run

```bash
$ grep -m 1 -n "^00:" ./ MY-DEVICE_2019-01-01_2300UTC.dat
4222:00:00:00.480459 IP 127.0.0.1.55074 > 127.0.0.1.8761: tcp 379
$
```

The command above returned the line in this log file that contains "00:" at the beginning, but only the 1st occurence (`-m 1`), and the output includes the line number (`-n`).  From this example output, you can see _line 4222_ is the first line with the timestamp of 00:. Split the file using `head` and `tail`:

```bash
$ head -n 4221 ./MY-DEVICE_2019-01-01_2300UTC.dat > ./MY-DEVICE_2019-01-01_2300_2359.dat
$ tail +n 4222 ./MY-DEVICE_2019-01-01_2300UTC.dat > ./MY-DEVICE_2019-01-02_0000_0100.dat
```
Now you can use `packetCounetr.sh` for each file.


## Questions & Comments
Please contact the primary author Nathan Oyama <nathan.oyama[[at]]berkeley.edu>.

_Last modified: September 12, 2018 by Nahtan Oyama_
