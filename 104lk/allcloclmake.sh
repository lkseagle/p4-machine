#!/bin/bash
ssh -p 9114 root@192.168.199.114 "cd /home/sinet71/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9114 root@192.168.199.114 "cd /home/sinet71/lk; sudo ifconfig eno2 10.2.2.12 up; nohup sudo ptp4l -i eno2 -m -H > makeclock2.txt 2>&1 &"
ssh -p 9114 root@192.168.199.114 "cd /home/sinet71/lk; sudo ifconfig eno3 10.2.2.13 up; nohup sudo ptp4l -i eno3 -m -H > makeclock3.txt 2>&1 &"
echo "114 : all clock are maked!"
echo "----------------------------------------------"

ssh -p 9108 root@192.168.199.108 "cd /home/sinet41/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9108 root@192.168.199.108 "cd /home/sinet41/lk; sudo ifconfig enp59s0f3 10.2.2.51 up; nohup sudo ptp4l -i enp59s0f3 -s -m -H > makeclock1.txt 2>&1 &"
ssh -p 9108 root@192.168.199.108 "cd /home/sinet41/lk; sudo ifconfig eno3 10.2.2.52 up; nohup sudo ptp4l -i eno3 -m -H > makeclock2.txt 2>&1 &"
ssh -p 9108 root@192.168.199.108 "cd /home/sinet41/lk; sudo ifconfig eno4 10.2.2.53 up; nohup sudo ptp4l -i eno4 -m -H > makeclock3.txt 2>&1 &"
echo "108 : all clock are maked!"
echo "----------------------------------------------"

ssh -p 9104 root@192.168.199.104 "cd /home/sinet21/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9104 root@192.168.199.104 "cd /home/sinet21/lk; sudo ifconfig enp94s0f1 10.2.2.21 up; nohup sudo ptp4l -i enp94s0f1 -s -m -H > makeclock1.txt 2>&1 &"
ssh -p 9104 root@192.168.199.104 "cd /home/sinet21/lk; sudo ifconfig eno3 10.2.2.22 up; nohup sudo ptp4l -i eno3 -m -H > makeclock2.txt 2>&1 &"
ssh -p 9104 root@192.168.199.104 "cd /home/sinet21/lk; sudo ifconfig eno4 10.2.2.23 up; nohup sudo ptp4l -i eno4 -m -H > makeclock3.txt 2>&1 &"
echo "104 : all clock are maked!"
echo "----------------------------------------------"

ssh -p 9106 root@192.168.199.106 "cd /home/sinet31/lk;  nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9106 root@192.168.199.106 "cd /home/sinet31/lk; sudo ifconfig eno2 10.2.2.31 up; nohup sudo ptp4l -i eno2 -s -m -H > makeclock1.txt 2>&1 &"
ssh -p 9106 root@192.168.199.106 "cd /home/sinet31/lk; sudo ifconfig eno3 10.2.2.32 up; nohup sudo ptp4l -i eno3 -s -m -H > makeclock2.txt 2>&1 &"
ssh -p 9106 root@192.168.199.106 "cd /home/sinet31/lk; sudo ifconfig enp59s0f3 10.2.2.33 up; nohup sudo ptp4l -i enp59s0f3 -m -H > makeclock3.txt 2>&1 &"
echo "106 : all clock are maked!"
echo "----------------------------------------------"

ssh -p 9112 root@192.168.199.112 "cd /home/sinet61/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9112 root@192.168.199.112 "cd /home/sinet61/lk; sudo ifconfig eno2 10.2.2.61 up; nohup sudo ptp4l -i eno2 -s -m -H > makeclock1.txt 2>&1 &"
ssh -p 9112 root@192.168.199.112 "cd /home/sinet61/lk; sudo ifconfig eno3 10.2.2.62 up; nohup sudo ptp4l -i eno3 -s -m -H > makeclock2.txt 2>&1 &"
ssh -p 9112 root@192.168.199.112 "cd /home/sinet61/lk; sudo ifconfig enp59s0f2 10.2.2.63 up; nohup sudo ptp4l -i enp59s0f2 -m -H > makeclock3.txt 2>&1 &"
echo "112 : all clock are maked!"
echo "----------------------------------------------"

ssh -p 9110 root@192.168.199.110 "cd /home/sinet51/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9110 root@192.168.199.110 "cd /home/sinet51/lk; sudo ifconfig eno2 10.2.2.41 up; nohup sudo ptp4l -i eno2 -s -m -H > makeclock1.txt 2>&1 &"
ssh -p 9110 root@192.168.199.110 "cd /home/sinet51/lk; sudo ifconfig eno3 10.2.2.42 up; nohup sudo ptp4l -i eno3 -s -m -H > makeclock2.txt 2>&1 &"
echo "110 : all clock are maked!"
echo "----------------------------------------------"




