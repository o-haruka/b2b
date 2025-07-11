#!/bin/bash

# エラー出力を抑制
exec 2>/dev/null

# バナーの定義
BANNER="===== System Monitoring Report ====="

# ARCHITECTURE
arch=$(uname -a)

# CPU PHYSICAL
p_cpu=$(grep "physical id" /proc/cpuinfo | wc -l)

# CPU VIRTUAL
v_cpu=$(grep "processor" /proc/cpuinfo | wc -l)

# RAM
ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_used=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_rate=$(free --mega | awk '$1 == "Mem:" {printf("%.2f", $3/$2 * 100)}')

# DISK
disk_total=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf "%.1f", disk_t/1024}')
disk_used=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
disk_rate=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d"), disk_u/disk_t*100}')

# CPU LOAD
cpu_idle_percent=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpu_usage_percent=$(expr 100 - $cpu_idle_percent)
cpu_usage_formatted=$(printf "%.1f" $cpu_usage_percent)

# LAST BOOT
last_boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# LVM USE
use_lvm=$(lsblk | grep -q "lvm" && echo yes || echo no)

# TCP CONNECTIONS
tcp_connection=$(ss -ta | grep "ESTAB" | wc -l)

# USER COUNT
user_count=$(users | wc -w)

# NETWORK
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# SUDO
sudo=$(journalctl _COMM=sudo| grep COMMAND | wc -l)

echo $BANNER;
printf "#Architecture: $arch\n";
printf "#CPU physical: $p_cpu\n";
printf "#vCPU: $v_cpu\n";
printf "#Memory Usage: $ram_used/${ram_total}MB (${ram_rate}%%)\n";
printf "#Disk Usage: $disk_used/${disk_total}Gb (${disk_rate}%%)\n";
printf "#CPU load: $cpu_usage_formatted%%\n";
printf "#Last boot: $last_boot\n";
printf "#LVM use: $use_lvm\n";
printf "#Connections TCP: $tcp_connection ESTABLISHED\n";
printf "#User log: $user_count\n";
printf "#Network: IP $ip ($mac)\n";
printf "#Sudo: $sudo cmd\n";