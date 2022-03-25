#!/bin/bash
ssh -p 9114 root@192.168.199.114 "cd /home/sinet71/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9114 root@192.168.199.114 "cd /home/sinet71/lk; nohup sudo rm makeclock* "


echo "114 : all clock are closed!"
echo "----------------------------------------------"

ssh -p 9108 root@192.168.199.108 "cd /home/sinet41/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9108 root@192.168.199.108 "cd /home/sinet41/lk; nohup sudo rm makeclock*"

echo "108 : all clock are closed!"
echo "----------------------------------------------"

ssh -p 9104 root@192.168.199.104 "cd /home/sinet21/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9104 root@192.168.199.104 "cd /home/sinet21/lk; nohup sudo rm makeclock*"

echo "104 : all clock are closed!"
echo "----------------------------------------------"
ssh -p 9106 root@192.168.199.106 "cd /home/sinet31/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9106 root@192.168.199.106 "cd /home/sinet31/lk; nohup sudo rm makeclock*"

echo "106 : all clock are closed!"
echo "----------------------------------------------"
ssh -p 9112 root@192.168.199.112 "cd /home/sinet61/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9112 root@192.168.199.112 "cd /home/sinet61/lk; nohup sudo rm makeclock*"


echo "112 : all clock are closed!"
echo "----------------------------------------------"

ssh -p 9110 root@192.168.199.110 "cd /home/sinet51/lk; nohup sudo ./shut_ptp4l.sh > pctp4lclosed.txt 2>&1"
ssh -p 9110 root@192.168.199.110 "cd /home/sinet51/lk; nohup sudo rm makeclock*"

echo "110 : all clock are closed!"
echo "----------------------------------------------"




