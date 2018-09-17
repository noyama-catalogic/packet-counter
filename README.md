# Packet Counter (pre-alpha)
Count packets for each port, for each source/destination IP address every second, within a given time range.

## System Requirement
### Target Device
* tcpdump (Linux)
* WinDump (Windows)

### Device that runs Packet Counter
Packet Counter does not need to be used on a target device. For example, you may capture packets on RaspberryPi, move your packet record files into your PC and run Packet Counter to count packets.
* UNIX environment
  * e.g. Linux, Windows (MSYS2, Cygwin), Windows Subsystems for Linux (WSL, aka. _Bash for Windows 10_)
* Bash (v4+)
* AWK

### Spreadsheet application (optional)
The script generates packet count result in two CSV files: (1) incoming packets and (2) outgoing packets. You can use any CSV viewers, but it is advised to use a spreadsheet application that supports easy-to-use filters such as
* Microsoft Excel
* LibreOffice

## Usage
Run the following script on the target device:
```bash
$ tcpdump -i <interface> -nnq > ./<file>
```
To end capturing packets, press [Ctrl] + [c].  In UNIX environment, you may use `any` for <IP>.  For Windows users, see Questoin 2.

Run the following command on the dcevice you want to capture packets.
```bash
$ bash ./packetCounter.sh <file> <IP> <start time> <end time>
```
* `<file>`: A packet record file you get by running the following command on the target device:
* `<IP>`: The IP address of the target device. E.g. 10.20.30.40.
* `<start time>`: The start time you want to retrieve. The output will start from the first records with the timestamps which is the same or larger than the given start time. Use the <HH>, <HH:mm> or <HH:mm:ss> format. E.g. 09:50.
* `<end time>`: The end time you want to retrieve. The output will end at one line before the first record whose timestamp is one second ahead of the given end time. The Use the <HH>, <HH:mm> or <HH:mm:ss> format. E.g. 12:34:56.

### Example:
Consider you logged into your computer 10.20.30.40, ran the tcpdump command below and get the packet record file:
```bash
$ tcpdump -i any -nnq > ./$(hostname)_$(env TZ=UTC date +%F_%H%M)UTC.dat
```
If you want to retrieve the packet count record with the timestamps between 01:50 and 02:05, run the following command:
```bash
$ bash ./packetCounter.sh target_pc_2018-09-07_0556UTC.dat 10.20.30.40 01:50 02:05
```


## Questions and Answers
### 1. About General Usage
**Question 1.** I captured packets over midnight: from 23:00 through 01:00 on the next day.  But this script doesn't support a log file with multiple dates.  What should I do?

_Ans._ Split your log files using text processing tools as needed.  For example, if you have a UNIX environment with you, run

```bash
$ grep -m 1 -n "^00:" ./ MY-DEVICE_2019-01-01_2300UTC.dat
4222:00:00:00.480459 IP 127.0.0.1.55074 > 127.0.0.1.8761: tcp 379
$
```

The command above returned the line in this log file that contains "00:" at the beginning, but only the 1st occurence (`-m 1`), and the output includes the line number (`-n`).  From this example output, you can see _line 4222_ is the first line with the timestamp of 00:. Split the file using `head` and `tail`:

```bash
$ head -4221 ./MY-DEVICE_2019-01-01_2300UTC.dat > ./MY-DEVICE_2019-01-01_2300_2359.dat
$ tail +4222 ./MY-DEVICE_2019-01-01_2300UTC.dat > ./MY-DEVICE_2019-01-02_0000_0100.dat
```
Now you can use `packetCounetr.sh` for each file.

### 2. About Windows Support
**Question 2.1.** Does Packet Counter support Windows?

_Ans._ _Yes!_ You can capture packets on Windows PC and run _Packet Counter_ on Windows PC too.


**Question 2.2.** How can I capture packets from Windows?

_Ans._ Install pcap.exe and run WinDump.exe to capture packets on your Windows system in the similar fashion, i.e.,

```bash
WinDump.exe -D                              # Identify an interface ID
WinDump.exe -i <interface> -nnq > ./<file>
```
If you are using PowerShell, you may use the following command which puts the user domain name and the timestamp into the output filename:

```powershell
WinDump.exe -i <interface> -nnq `
> ./$([System.Environment]::UserDomainName) + "_" + $(Get-Date).ToUniversalTime().ToString("yyyy-MM-dd_hhmm") + "UTC"
```

Unlike tcpdump for UNIX, WinDump.exe does not support `ANY` for `<interface>`. For more information on WinDump.exe, see https://www.winpcap.org/windump/ .

**Question 2.3.** How can I run _Packet Counter_ on Windows?

_Ans._ Use a UNIX environment on Windows: Cygwin, MSYS2 or Windows Subsystem for Linux (WSL, aka. Bash for Windows 10).


## Questions & Comments
Please contact the primary developer Nathan Oyama <nathan.oyama[[at]]berkeley.edu>.

_Last modified: September 12, 2018 by Nahtan Oyama_
