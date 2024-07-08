#!/bin/bash

# Architecture

architecture=$(uname -a)

# CPUS

cpus=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
vcpus=$(cat /proc/cpuinfo | grep processor | wc -l)

# RAM

ram_used=$(free --mega | grep Mem |awk '{print $3}')
ram_total=$(free --mega | grep Mem |awk '{print $2}')
ram_percentage=$(echo "scale=2; $ram_used * 100 / $ram_total" | bc -l)

# Disk
disk_used=$(df -m | grep /dev | grep -v /boot | awk '{mem_use += $3} END {print mem_use}')
disk_total_mb=$(df -m | grep /dev | grep -v /boot | awk '{mem_use += $2} END {print mem_use}')
disk_total_gb=$(echo "scale=1; $disk_total_mb / 1024" | bc -l)
disk_percentage=$(echo "scale=0; $disk_used * 100 / $disk_total_mb" | bc -l)

# CPU load
cpu_idle=$(vmstat | tail -n 1 | awk '{print $15}')
cpu_load=$((100 - $cpu_idle))

# Last reboot

last_boot=$(who -b | awk '{printf "%s %s", $3, $4}')

# LVM

lvm_used=$(if [ $(lsblk | grep lvm | wc -l) -gt 0 ]; then echo 'Yes'; else echo 'No'; fi)

# TCP

active_tcp=$(ss -s | grep estab | awk '{print $4}' | cut -d, -f1)

# Logged users

user_log=$(who | wc -l)

# Address

ip_addr=$(ip addr | grep global | awk '{print $2}' | cut -d/ -f1)
mac=$(ip addr | grep link/ether | awk '{print $2}')

# Sudo commands

sudo_cmd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

echo \
"	#Architecture: $architecture
	#CPU physical: $cpus
	#vCPU: $vcpus
	#Memory Usage: $ram_used/${ram_total}MB ($ram_percentage%)
	#Disk Usage: $disk_used/${disk_total_gb}GB ($disk_percentage%)
	#CPU load: $cpu_load%
	#Last boot: $last_boot
	#LVM use: $lvm_used
	#Connections TCP: $active_tcp ESTABLISHED
	#User log: $user_log
	#Network: IP $ip_addr ($mac)
	#Sudo: $sudo_cmd cmd" \
| wall;
