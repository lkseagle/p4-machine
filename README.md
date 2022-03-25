# git-p4machine
### Thank you very much for paying attention to my work, and I hope my work can help you!!!
######################Introduction:    
    This project code is applied to the P4-based programmable switch machine code. If readers want to learn the content of the project, they can refer to my other project code linkmonitor https://github.com/lkseagle/linkmonitor, which working on the virtual machine.   
    Taking into account the limitations of the machine and the promotion work of the research, I have combined the code on the line. The project code integrates the user's traffic simulation with the sending and receiving operations of the INT framework. This project implements INT detection, P4-based parallel data transmission, and network load balancing control applications using an actual P4 programmable switch and two servers.  
######################Design topogy and making system configuration.  
The network is constructed according to the topology map pair and placed in the corresponding position according to the corresponding file content. Install a P4 executive module on each switch（https://github.com/p4lang/tutorials）. Install the TensorFlow module on the server.  
######################Experemental steps   
Note: ALL the flowing steps are performed in the packge of /home/sinet/lk  
104: sudo ./openallbmv2.sh  
104: sudo ./speedmake.sh    
106: simple_switch_CLI --thrift-port 9092 2300  
server1: sudo ./nserv11.sh  
server2: sudo ./switch_enp8s0.sh  
server1: sudo python intsend.py  
server2: sudo python intreceive.py   
######At this time, the cmd window show datas, which means you realize the basic settings.  
Then, inject traffic into the network for data monitoring.   
server1: iperf3 -c 10.168.198.81 -i 1 -t 100  
server2: iperf3 -s -i 1  
Finally, doing offine neural network traning and online scheduling.  
server2: sudo python DPPO.py ## Training for neural parameters updating.  
server2: sudo python wppolearn.py ### Doing online transmission control.  
################Conclusion  
According to the needs of their own projects, readers can arbitrarily adjust and modify the parsing module in the INT framework to obtain other network attributes. Then the relevant parameters of the neural network can be modified to control different outputs according to the content of the network properties.  

Finally, thank you very much for paying attention to my work, and I hope my work can help you, thank you！！！  
