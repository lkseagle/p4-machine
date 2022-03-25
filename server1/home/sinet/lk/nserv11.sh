sudo ifconfig enp8s0 up
sudo ethtool -K enp8s0 gro off
sudo ethtool -K enp8s0 gso off
sudo ethtool -K enp8s0 rx off
sudo ethtool -K enp8s0 tx off
sudo ifconfig enp8s0 10.168.199.80/24 up
sudo route add -net 10.168.198.0/24 gw 10.168.199.85 dev enp8s0
