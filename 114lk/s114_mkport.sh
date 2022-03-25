sudo ifconfig eno3 up
sudo ethtool -K eno3 gro off
sudo ethtool -K eno3 gso off
sudo ethtool -K eno3 rx off
sudo ethtool -K eno3 tx off

sudo ifconfig eno4 up
sudo ethtool -K eno4 gro off
sudo ethtool -K eno4 gso off
sudo ethtool -K eno4 rx off
sudo ethtool -K eno4 tx off

sudo ifconfig eno2 up
sudo ethtool -K eno2 gro off
sudo ethtool -K eno2 gso off
sudo ethtool -K eno2 rx off
sudo ethtool -K eno2 tx off



sudo ifconfig eno4 10.168.199.85/24 up
sudo simple_switch --thrift-port 9096 -i 1@eno4 -i 2@eno2 -i 3@eno3 link_monitor.json
