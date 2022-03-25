#!/usr/bin/env python

from probe_hdrs import *

def expand(x):
    yield x
    while x.payload:
        x = x.payload
        yield x

def handle_pkt(pkt):
    if ProbeData in pkt:
        data_layers = [l for l in expand(pkt) if l.name=='ProbeData']  ####collect node by reversely
        for sw in data_layers:
            print "Switch {} - Port {}: ingress_time {} egress_time {} in-packets {} out-packets {} q-Length: {} ".format(sw.swid, sw.port,sw.ingress_time, sw.egress_time, sw.pckcont, sw.enpckcont, sw.qdepth)
        print "\n"     
        j=0
        for i in range(len(data_layers)): ####collect node by reversely/
            #print "Switch {} - Port {}: cur_time {} in-packets {} out-packets {} q-Length: {} ".format(sw.swid, sw.port,sw.cur_time, sw.pckcont, sw.enpckcont, length)
            if(j>0):
                utilization = 0 if data_layers[i].egress_time == data_layers[i].last_time else 8.0*data_layers[i].byte_cnt/(data_layers[i].egress_time - data_layers[i].last_time)
                length=data_layers[i].qdepth
                droppkt=data_layers[i].enpckcont-data_layers[i-1].pckcont ####befor.egress---last.ingress=link+node drop
                delay=data_layers[i-1].ingress_time-data_layers[i].egress_time
                print "Switch {}: delay:{}us bw:{} Mbps  droppkt:{} q-Length:{}".format(data_layers[i].swid, delay, utilization, droppkt, length)    
            j=j+1       
        print "\n"
       
def main():
    iface = 'enp8s0'
    print "sniffing on {}".format(iface)
    sniff(iface = iface,
          prn = lambda x: handle_pkt(x))

if __name__ == '__main__':
    main()
