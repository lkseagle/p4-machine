sudo ifconfig enp94s0f1 up
sudo ethtool -K enp94s0f1 gro off
sudo ethtool -K enp94s0f1 gso off
sudo ethtool -K enp94s0f1 rx off
sudo ethtool -K enp94s0f1 tx off

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


sudo simple_switch --thrift-port 9091 -i 1@enp94s0f1 -i 2@eno3 -i 3@eno4 link_monitor.json