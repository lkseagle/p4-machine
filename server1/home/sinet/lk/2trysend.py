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
##src='fe80::ad7b:2cc4:e7c3:9e80%11'
   def sendpak(self):
        probe_pkt = Ether(dst='ff:ff:ff:ff:ff:ff', src=get_if_hwaddr('enp8s0')) / \
                Probe(hop_cnt=0,learn=2) / \
                ProbeFwd(egress_spec=2) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3) / \
                ProbeFwd(egress_spec=3)
       
        try:
            sendp(probe_pkt, iface='enp8s0')
        except KeyboardInterrupt:
            sys.exit()

if __name__ == '__main__':
     senders=sender()
    # for i in range(100):
     senders.sendpak()
     time.sleep(1)
