sudo ifconfig eno2 up
sudo ethtool -K eno2 gro off
sudo ethtool -K eno2 gso off
sudo ethtool -K eno2 rx off
sudo ethtool -K eno2 tx off

sudo ifconfig eno3 up
sudo ethtool -K eno3 gro off
sudo ethtool -K eno3 gso off
sudo ethtool -K eno3 rx off
sudo ethtool -K eno3 tx off

sudo ifconfig enp59s0f2 up
sudo ethtool -K enp59s0f2 gro off
sudo ethtool -K enp59s0f2 gso off
sudo ethtool -K enp59s0f2 rx off
sudo ethtool -K enp59s0f2 tx off

sudo ifconfig eno4 up
sudo ethtool -K eno4 gro off
sudo ethtool -K eno4 gso off
sudo ethtool -K eno4 rx off
sudo ethtool -K eno4 tx off


sudo ifconfig enp59s0f2 10.168.198.86/24 up
sudo ifconfig eno4 10.168.198.87/24 up
sudo simple_switch --thrift-port 9093 -i 1@eno2 -i 2@eno3 -i 3@enp59s0f2 -i 4@eno4 link_monitor.json