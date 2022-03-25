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


def run():
    f1 = "/home/sinet/lk/message/ranmes.txt"
    #read states
    fo = open("/home/sinet/lk/message/singledata.txt", "r")  
    for line in fo.readlines():
        if line.strip()=='':
           continue
        line = line.strip()
    mes = line.split(' ')
    #print mes
    #b = random.sample(range(8,10),1)
    #b=[59,2,6,12,1]
    b =[np.random.randint(1,100) for js in range(5)]
    if(len(mes)==26):
        learnset(b)
        actions=' '.join(str(i) for i in b)
    #####record action t and state t
        with open(f1,"a") as file:   
           file.write(str(actions)+" "+str(line)+'\n')
        fo.close()
       
     

if __name__ == "__main__":
 # for i in range(100):
       run()  ###make the tuple<action,states>
      # senders=sender()
      # senders.sendpak() ####collect next states.
       time.sleep(2)

