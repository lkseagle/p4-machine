from probe_hdrs import *
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

result=""
alresult=""
senid=0
oldsenid2=0
oldsenid3=0
oldsenid4=0
oldsenid5=0
true2=False
true3=False
true4=False

def expand(x):
    yield x
    while x.payload:
        x = x.payload
        yield x

def makedata2(data_layers,intenal):
        global result
        result=""
        thput=data_layers[0].pckcont/intenal
        result=result+str(thput)+" "
        for i in range(1,len(data_layers)):
            byte_cnt=data_layers[i].byte_cnt/intenal
            utilization = 0 if data_layers[i].egress_time == data_layers[i].last_time else 8.0*byte_cnt/(data_layers[i].egress_time - data_layers[i].last_time)
            length=data_layers[i].qdepth
            droppkt=(data_layers[i].enpckcont-data_layers[i-1].pckcont)/intenal ####befor.egress---last.ingress=link+node drop
            delay=data_layers[i-1].ingress_time-data_layers[i].egress_time
            resut="2222-Switch {}:prot:{} delay:{}us bw:{} Mbps  droppkt:{} q-Length:{} \n".format(data_layers[i].swid,data_layers[i].port, delay, utilization, droppkt, length)  
            result=result+"{} {} {} {} ".format(delay, utilization, droppkt, length)       
            print resut 

def makedata3(data_layers,intenal):
        global result
        for i in range(2,len(data_layers)-1):
            byte_cnt=data_layers[i].byte_cnt/intenal
            utilization = 0 if data_layers[i].egress_time == data_layers[i].last_time else 8.0*byte_cnt/(data_layers[i].egress_time - data_layers[i].last_time)
            length=data_layers[i].qdepth
            droppkt=(data_layers[i].enpckcont-data_layers[i-1].pckcont)/intenal ####befor.egress---last.ingress=link+node drop
            delay=data_layers[i-1].ingress_time-data_layers[i].egress_time
            resut="33333-Switch {}:prot:{} delay:{}us bw:{} Mbps  droppkt:{} q-Length:{} \n".format(data_layers[i].swid,data_layers[i].port, delay, utilization, droppkt, length)  
            result=result+"{} {} {} {} ".format(delay, utilization, droppkt, length)      
            print resut
        print result
        f1 = "/home/sinet/lk/message/h3.txt"
        with open(f1,"w") as file1:   
              #file.write(str(state)+" "+str(action)+" "+str(reward)+" "+str(r)+'\n')        
              file1.write(result)
        file1.close()
        result=""

def makedata4(data_layers,intenal):
        global alresult
        alresult=""
        thput=data_layers[0].pckcont/intenal
        alresult=alresult+str(thput)+" "
        for i in range(1,len(data_layers)):
            byte_cnt=data_layers[i].byte_cnt/intenal
            utilization = 0 if data_layers[i].egress_time == data_layers[i].last_time else 8.0*byte_cnt/(data_layers[i].egress_time - data_layers[i].last_time)
            length=data_layers[i].qdepth
            droppkt=(data_layers[i].enpckcont-data_layers[i-1].pckcont)/intenal####befor.egress---last.ingress=link+node drop
            delay=data_layers[i-1].ingress_time-data_layers[i].egress_time
            alresul="444444-Switch {}: prot:{} delay:{}us bw:{} Mbps  droppkt:{} q-Length:{} \n".format(data_layers[i].swid,data_layers[i].port, delay, utilization, droppkt, length)  
            alresult=alresult+"{} {} {} {} ".format(delay, utilization, droppkt, length)       
            print alresul

def makedata5(data_layers,intenal):
        global alresult
        for i in range(2,len(data_layers)-1):
            byte_cnt=data_layers[i].byte_cnt/intenal
            utilization = 0 if data_layers[i].egress_time == data_layers[i].last_time else 8.0* byte_cnt/(data_layers[i].egress_time - data_layers[i].last_time)
            length=data_layers[i].qdepth
            droppkt=(data_layers[i].enpckcont-data_layers[i-1].pckcont)/intenal ####befor.egress---last.ingress=link+node drop
            delay=data_layers[i-1].ingress_time-data_layers[i].egress_time
            alresul="55555-Switch {}: port:{} delay:{}us bw:{} Mbps  droppkt:{} q-Length:{} \n".format(data_layers[i].swid,data_layers[i].port, delay, utilization, droppkt, length)  
            alresult=alresult+"{} {} {} {}".format(delay, utilization, droppkt, length)      
            print alresul
        print alresult
        ########the first two path data for allpathdata to connect next.
        fo = open("/home/sinet/lk/message/h3.txt", "r")  
        for line in fo.readlines():
            if line.strip()=='':
               continue
            line = line.strip()
            linee=line.split(' ')
        fo.close()
       # print(len(linee))
       # print(len(alresult.split(' ')))
        if(len(linee)==17 and len(alresult.split(' '))==17):
            ########follows are making for allpathdata for analysis.
            f11 = "/home/sinet/lk/message/allpathdata.txt"
            with open(f11,"a") as file2:   
                  #file.write(str(state)+" "+str(action)+" "+str(reward)+" "+str(r)+'\n')
                file2.write(line+" "+alresult+'\n')
                ########follows are making for single pathdata for read learning.
            file2.close()
            f2 = "/home/sinet/lk/message/singledata.txt"
            with open(f2,"w") as file3:   
                #file.write(str(state)+" "+str(action)+" "+str(reward)+" "+str(r)+'\n')
                file3.write(line+" "+alresult+'\n')
            file3.close()
            print('###############################################')
        alresult=""


def handle_pkt(pkt):
    global senid
    global oldsenid2
    global oldsenid3
    global oldsenid4
    global oldsenid5
    global true2
    global true3
    global true4
    global true5
    if ProbeData in pkt:
        data_layers = [l for l in expand(pkt) if l.name=='ProbeData']
        probelen = [s for s in expand(pkt) if s.name=='Probe']
        ####each makedata is reversely. 
        if(probelen[0].learn==2 and probelen[0].count > senid):
            internal=probelen[0].count-oldsenid2
            senid=probelen[0].count
            oldsenid2=probelen[0].count
            makedata2(data_layers,internal)
            true2=True ###show there have data
            true3=False
            true4=False
        elif(probelen[0].learn==3 and probelen[0].count==senid and true2==True and true3==False):
            internal=probelen[0].count-oldsenid3
            oldsenid3=probelen[0].count
            makedata3(data_layers,internal)
            true3=True
        if(probelen[0].learn==4 and probelen[0].count==senid and true3==True and true4==False):
            internal=probelen[0].count-oldsenid4
            oldsenid4=probelen[0].count
            makedata4(data_layers,internal)
            true4=True
        elif(probelen[0].learn==5 and probelen[0].count==senid and true4==True):
            internal=probelen[0].count-oldsenid5
            oldsenid5=probelen[0].count
            makedata5(data_layers,internal)
            true2=False
            true3=False
            true4=False
            
            
def main():
    iface = 'enp8s0'
    print "sniffing on {}".format(iface)
    sniff(iface = iface,
          prn = lambda x: handle_pkt(x))

if __name__ == '__main__':
    main()
