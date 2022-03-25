#!/bin/bash
ssh -p 9104 root@192.168.199.104 "cd /home/sinet21/lk; sudo ethtool -s eno3 speed 100 duplex full autoneg on; sudo ethtool -s eno4 speed 100 duplex full autoneg on "
echo "104's eno3 eno4 eth are made 100M !"

echo "----------------------------------------------"
ssh -p 9106 root@192.168.199.106 "cd /home/sinet31/lk; sudo ethtool -s enp59s0f3 speed 100 duplex full autoneg on "
echo "106's enp59s0f3 eth is made 100M !"
echo "----------------------------------------------"
ssh -p 9108 root@192.168.199.108 "cd /home/sinet41/lk; sudo ethtool -s eno4 speed 100 duplex full autoneg on "
echo "108's eno4 eth is made 100 M !"
echo "----------------------------------------------"


