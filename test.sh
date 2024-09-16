#!/usr/bin/env bash  

#Architecture
arch=$(uname -a)

#CPUs
cpu_phys=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
cpu_vir=$(grep "^processor" /proc/cpuinfo | wc -l)

#RAM
ram_tot=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_use=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_per=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

#Disk Usage
disk_tot=$(df -BG | awk '$1 ~ /^\/dev\// && $NF != "/boot" {tot += $2} END {print tot}')
disk_use=$(df -BM | awk '$1 ~ /^\/dev\// && $NF != "/boot" {used+=$3} END {print used}')
disk_per=$((($disk_use * 100) / ($disk_tot *1024)))

#disk_per=$(printf "%.0f" "$(echo "scale=4; (($disk_use / 1024) / $disk_tot) * 100" | bc)")

#CPU Load
cpu_load=$(top -bn1 | grep '^%Cpu' | awk '{printf("%.1f%%"), $2 + $4}')

#Last boot
boot_last=$(who -b | awk '$1 == "system" {print $3 " " $4}')

#LVM Use?
lvm=$(lsblk -o TYPE | grep -qw "lvm" && echo "yes" || echo "no")

#TCP Connections
tcp=$(ss -t state established | wc -l)

#User Count
user_count=$(users | wc -w)

#IP and MAC Address
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link show | grep "ether" | awk '{print $2}')

#Number of sudo Commands
cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
  
wall "    #Architecture: $arch
    #CPU physical: $cpu_phys
    #vCPU: $cpu_vir
    #Memory Usage: $ram_use/${ram_tot}MB ($ram_per%)
    #Disk Usage: $disk_use/${disk_tot}Gb ($disk_per%)
    #CPU load: $cpu_load
    #Last boot: $boot_last
    #LVM use: $lvm
    #Connections TCP: $tcp ESTABLISHED
    #User log: $user_count
    #Network: IP $ip ($mac)
    #Sudo: $cmds cmd"
