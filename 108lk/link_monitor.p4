/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4  = 0x800;
const bit<16> TYPE_PROBE = 0x812;
const bit<16> TYPE_ARP = 0x0806;


/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

typedef bit<48> time_t;

header ethernet_t
{
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header arp_t
{
    bit<16>  hardware_type;
    bit<16>  protocol_type;
    bit<8>    HLEN;
    bit<8>    PLEN;
    bit<16>  OPER;
    bit<48>  sender_ha;
    bit<32>  sender_ip;
    bit<48>  target_ha;
    bit<32>  target_ip;  //totalen-224
}

header ipv4_t
{
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

// Top-level probe header, indicates how many hops this probe
// packet has traversed so far.
header probe_t
{
    bit<8> hop_cnt;
    bit<8> learn; //0 - INT, 1-learning set
	bit<32> count; // make record for many send packets, choose one from 10-intsend.py

}

// The data added to the probe by each switch at each hop.
header probe_data_t
{
    bit<1>    bos;
    bit<7>    swid;
    bit<8>    port;
    bit<32>   byte_cnt;
    bit<32>   pckcont;
    bit<32>   enpckcont;
	time_t    ingress_time;
    time_t    last_time;
    time_t    egress_time;
    bit<32>   qdepth;
}

// Indicates the egress port the switch should send this probe
// packet out of. There is one of these headers for each hop.
header probe_fwd_t
{
    bit<8>   egress_spec;
    bit<8>    swid;
    bit<8>    percent;
}

struct parser_metadata_t
{
    bit<8>  remaining;
}

struct metadata
{
    bit<8> egress_spec;
    parser_metadata_t parser_metadata;
    bit<9>  tempport;
    bit<32> tempcount;
    bit<32> threshold1;
    bit<32> threshold2;
    bit<7> sswid;
    bit<8> percc;
    bit<32> pktcont2;
	time_t  ingress_time;
}


struct headers
{
    ethernet_t              ethernet;
    arp_t                   arp;
    ipv4_t                  ipv4;
    probe_t                 probe;
    probe_data_t[10]  probe_data;
    probe_fwd_t[10]   probe_fwd;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata)
{

    state start
    {
        transition parse_ethernet;
    }

    state parse_ethernet
    {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType)
        {
TYPE_ARP:
            parse_arp;
TYPE_IPV4:
            parse_ipv4;
TYPE_PROBE:
            parse_probe;
        default:
            accept;
        }
    }

    state parse_ipv4
    {
        packet.extract(hdr.ipv4);
        transition accept;
    }

    state parse_probe
    {
        packet.extract(hdr.probe);
        meta.parser_metadata.remaining = hdr.probe.hop_cnt + 1;
        transition select(hdr.probe.hop_cnt)
        {
0:
            parse_probe_fwd;
        default:
            parse_probe_data;
        }
    }

    state parse_arp
    {
        packet.extract(hdr.arp);
        transition accept;
    }

    state parse_probe_data
    {
        packet.extract(hdr.probe_data.next);
        transition select(hdr.probe_data.last.bos)
        {
1:
            parse_probe_fwd;
        default:
            parse_probe_data;
        }
    }

    state parse_probe_fwd
    {
        packet.extract(hdr.probe_fwd.next);
        meta.parser_metadata.remaining = meta.parser_metadata.remaining - 1;
        // extract the forwarding data
        meta.egress_spec = hdr.probe_fwd.last.egress_spec;
        meta.percc= hdr.probe_fwd.last.percent;
        transition select(meta.parser_metadata.remaining)
        {
         0:
            accept;
        default:
            parse_probe_fwd;
        }
    }
}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta)
{
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata)
{
    register< bit<32> >(10) count;
    register< bit<32> >(10) threshold;
    register<bit<32>>(8) contpkts;

    action drop()
    {
        mark_to_drop(standard_metadata);
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port)
    {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }
    action ipv4_forward1(macAddr_t dstAddr, egressSpec_t port)
    {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }
    action ipv4_forward2(macAddr_t dstAddr, egressSpec_t port)
    {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm
    {
        key = {
             hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    table ipv4_lpm1
    {
        key = {
            hdr.ipv4.dstAddr:
            lpm;
        }
        actions = {
            ipv4_forward1;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }
    table ipv4_lpm2
    {
        key = {
         hdr.ipv4.dstAddr:lpm;
        }
        actions = {
            ipv4_forward2;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    action set_swid(bit<7> swid)
    {
        meta.sswid = swid;

    }
    table swid
    {
        actions = {
            set_swid;
            NoAction;
        }
        default_action = NoAction();
    }

    bit<32>cg=0;
    bit<32>twop=0;
    bit<32> contpp;
    bit<32> new_cont;

    apply
    {
        if (hdr.arp.isValid())
        {
            //deal with arp packet
            if (hdr.arp.target_ip == 0x0aa8c651)
            {
                //ask who is 10.168.\\\\\198.81
                hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
                hdr.ethernet.srcAddr = 0x3448edf8f343;
                hdr.arp.OPER = 2;
                hdr.arp.target_ha = hdr.arp.sender_ha;
                hdr.arp.target_ip = hdr.arp.sender_ip;
                hdr.arp.sender_ip = 0x0aa8c651;
                hdr.arp.sender_ha = 0x3448edf8f343;
                standard_metadata.egress_spec = standard_metadata.ingress_port;
            }
            else if (hdr.arp.target_ip  == 0x0aa8c750)
            {
                //ask who is 10.168.\\\\\199.80
                hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
                hdr.ethernet.srcAddr = 0xb026289ce306;
                hdr.arp.OPER = 2;
                hdr.arp.target_ha = hdr.arp.sender_ha;
                hdr.arp.target_ip = hdr.arp.sender_ip;
                hdr.arp.sender_ip = 0x0aa8c750;
                hdr.arp.sender_ha = 0xb026289ce306;
                standard_metadata.egress_spec = standard_metadata.ingress_port;
            }
        }
        else
        {

            // ingress packet conut--   increment byte cnt for this packet's port
            contpkts.read(contpp, (bit<32>)standard_metadata.ingress_port);
            contpp = contpp + 1;
            meta.pktcont2=contpp;  //trans to egress packetdata
            // reset the byte count when a probe packet passes through
            new_cont = (hdr.probe.isValid()) ? 0 : contpp;
            contpkts.write((bit<32>)standard_metadata.ingress_port, new_cont);
			
			meta.ingress_time=standard_metadata.ingress_global_timestamp;
            /////////////////////////////////////
            

            threshold.read(meta.threshold1,(bit<32>)0);
            threshold.read(meta.threshold2,(bit<32>)1);
            if(meta.threshold1==0)
            {
                meta.threshold1=(bit<32>)30;
                meta.threshold2=(bit<32>)100;
                threshold.write(0,meta.threshold1);
                threshold.write(1,meta.threshold2);
            }
            swid.apply();
            if (hdr.probe.isValid())
            {
                standard_metadata.egress_spec = (bit<9>)meta.egress_spec;
                hdr.probe.hop_cnt = hdr.probe.hop_cnt + 1;
                if(hdr.probe.learn == 1)
                {
                    threshold.write(0,(bit<32>)meta.percc);
                }
            }
            else if (hdr.ipv4.isValid())
            {

                count.read(cg,(bit<32>)0);
                count.read(meta.tempcount,(bit<32>)1);
                threshold.read(meta.threshold1,(bit<32>)0);
                threshold.read(meta.threshold2,(bit<32>)1);
                if(meta.threshold1<=50)
                {
                    twop=meta.threshold1;
                }
                else
                {
                    twop=meta.threshold2-meta.threshold1;
                }
                if(meta.tempcount<twop )
                {
                    if(cg==0)
                    {
                        meta.tempport = 1;
                        cg=1;
                        //ipv4_lpm1.apply();
                        count.write((bit<32>)0,cg);
                        count.write((bit<32>)1,meta.tempcount+1);
                    }
                    else
                    {
                        meta.tempport = 2;
                        cg=0;
                        count.write((bit<32>)0,cg);
                        //ipv4_lpm2.apply();

                    }
                }
                else if(meta.threshold1>50&&meta.tempcount<meta.threshold1)
                {
                    meta.tempport = 1;
                    count.write((bit<32>)1,meta.tempcount+1);
                }
                else if(meta.tempcount<(meta.threshold2-meta.threshold1))
                {
                    meta.tempport = 2;
                    count.write((bit<32>)1,meta.tempcount+1);
                }
                if((meta.tempcount+twop)>= meta.threshold2)
                {
                    count.write((bit<32>)0,(bit<32>)0);
                    count.write((bit<32>)1,(bit<32>)0);
                }
                if(meta.tempport == 1)
                {
                    ipv4_lpm1.apply();
                }
                else
                {
                    ipv4_lpm2.apply();
                }
            }
            else
            {
                ipv4_lpm.apply();
            }
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   ********************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata)
{

    // count the number of bytes seen since the last probe
    register<bit<32>>(8) byte_cnt_reg;
    // remember the time of the last probe
    register<time_t>(8) last_time_reg;
    register<bit<32>>(8) encontpkts;


    apply
    {
        bit<32> encontpp;
        bit<32> new_encont;
        // ingress packet conut--   increment byte cnt for this packet's port
        encontpkts.read(encontpp, (bit<32>)standard_metadata.egress_port);
        encontpp = encontpp + 1;
        // reset the byte count when a probe packet passes through
        new_encont = (hdr.probe.isValid()) ? 0 : encontpp;
        encontpkts.write((bit<32>)standard_metadata.egress_port, new_encont);
        /////////////////////////////////////

        bit<32> byte_cnt;
        bit<32> new_byte_cnt;
        time_t last_time;
        time_t egress_time = standard_metadata.egress_global_timestamp;
        // increment byte cnt for this packet's port
        byte_cnt_reg.read(byte_cnt, (bit<32>)standard_metadata.egress_port);
        byte_cnt = byte_cnt + standard_metadata.packet_length;
        // reset the byte count when a probe packet passes through
        new_byte_cnt = (hdr.probe.isValid()) ? 0 : byte_cnt;
        byte_cnt_reg.write((bit<32>)standard_metadata.egress_port, new_byte_cnt);

        if (hdr.probe.isValid())
        {
            // fill out probe fields
            hdr.probe_data.push_front(1);
            hdr.probe_data[0].setValid();
            if (hdr.probe.hop_cnt == 1)
            {
                hdr.probe_data[0].bos = 1;
            }
            else
            {
                hdr.probe_data[0].bos = 0;
            }
            // set switch ID field
            hdr.probe_data[0].swid=(bit<7>)meta.sswid;
            hdr.probe_data[0].port = (bit<8>)standard_metadata.egress_port;
            hdr.probe_data[0].byte_cnt = byte_cnt;
            hdr.probe_data[0].pckcont =meta.pktcont2;
            hdr.probe_data[0].enpckcont =encontpp;

            last_time_reg.read(last_time, (bit<32>)standard_metadata.egress_port);
            last_time_reg.write((bit<32>)standard_metadata.egress_port, egress_time);
			hdr.probe_data[0].ingress_time=meta.ingress_time;
            hdr.probe_data[0].last_time = last_time;
            hdr.probe_data[0].egress_time = egress_time;
            hdr.probe_data[0].qdepth = (bit<32>)standard_metadata.deq_qdepth;
        }
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   ***************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta)
{
    apply
    {
        update_checksum(
            hdr.ipv4.isValid(),
        {
            hdr.ipv4.version,
            hdr.ipv4.ihl,
            hdr.ipv4.diffserv,
            hdr.ipv4.totalLen,
            hdr.ipv4.identification,
            hdr.ipv4.flags,
            hdr.ipv4.fragOffset,
            hdr.ipv4.ttl,
            hdr.ipv4.protocol,
            hdr.ipv4.srcAddr,
            hdr.ipv4.dstAddr
        },
        hdr.ipv4.hdrChecksum,
        HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr)
{
    apply
    {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.probe);
        packet.emit(hdr.probe_data);
        packet.emit(hdr.probe_fwd);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
