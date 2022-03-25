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

sudo ifconfig enp59s0f3 up
sudo ethtool -K enp59s0f3 gro off
sudo ethtool -K enp59s0f3 gso off
sudo ethtool -K enp59s0f3 rx off
sudo ethtool -K enp59s0f3 tx off

sudo simple_switch --thrift-port 9092 --log-console -i 1@eno2 -i 2@eno3  -i 3@enp59s0f3 link_monitor.json
