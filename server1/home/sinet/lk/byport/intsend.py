import os
import re
import subprocess 
import time
import sched
import re
from time import sleep
import random
import datetime
import numpy as np
from numpy import array as matrix, arange
from probe_hdrs import *
class sender:
   def __init__(self):
       pass

   def sendpak(self):
        ########use learn={2,3,4,5} to respect aware-path. 0 is initination. 1 is to multi-threshold.
        ###path2{s1-3,s3-3,s5-3, s7-1} ## h3 receive
        probe_pkt2 = Ether(dst='ff:ff:ff:ff:ff:ff', src=get_if_hwaddr('enp8s0')) / \
                Probe(hop_cnt=0,learn=2) / \
                ProbeFwd(egress_spec=2) / \
                ProbeFwd(egress_spec=2) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3)
        ###path3{s1-3,s3-2,s2-5,s5-3,s7-1} ## h3 receive
        probe_pkt3 = Ether(dst='ff:ff:ff:ff:ff:ff', src=get_if_hwaddr('enp8s0')) / \
                Probe(hop_cnt=0,learn=3) / \
                ProbeFwd(egress_spec=2) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3) 
        ###path4{s1-4,s4-3,s6-3,s7-2} ## h4 receive
        probe_pkt4 = Ether(dst='ff:ff:ff:ff:ff:ff', src=get_if_hwaddr('enp8s0')) / \
                Probe(hop_cnt=0,learn=4) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3)
        ###path3s1-4,s4-1,s2-6,s6-3,s7-2} ## h4 receive
        probe_pkt5 = Ether(dst='ff:ff:ff:ff:ff:ff', src=get_if_hwaddr('enp8s0')) / \
                Probe(hop_cnt=0,learn=5) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=2) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3) 
        try:            
          for j in range(10):
            sendp(probe_pkt2, iface='enp8s0')
            sendp(probe_pkt4, iface='enp8s0')
            time.sleep(0.01)#0.03ms
            sendp(probe_pkt3, iface='enp8s0')
            time.sleep(0.1)
            sendp(probe_pkt5, iface='enp8s0')
        except KeyboardInterrupt:
            sys.exit()

if __name__ == '__main__':
     senders=sender()
     for i in range(100):
        senders.sendpak()
        time.sleep(2)
