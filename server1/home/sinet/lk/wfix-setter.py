# -*- coding: utf-8 -*-
#############################################################

####################################################################################
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


schedule = sched.scheduler(time.time,time.sleep)


def learnset(learnn):
    original=np.array([[2,1],[3,2],[2,3],[1,4],[1,5]])
    learnss=np.array(learnn).reshape(5,1)
    learnlist=np.hstack((original,learnss))
    probe_pkt = Ether(dst='ff:ff:ff:ff:ff:ff', src=get_if_hwaddr('enp8s0'))/Probe(hop_cnt=0,learn=1)
    for p in learnlist:
        try:
            probe_pkt = probe_pkt / ProbeFwd(egress_spec=p[0],swid=p[1],percent=p[2])
        except ValueError:
            pass
    while True:
        try:
            sendp(probe_pkt, iface='enp8s0')
            break
        except KeyboardInterrupt:
            sys.exit()
     

if __name__ == "__main__":
    b=[59,2,6,12,90]
    learnset(b)


