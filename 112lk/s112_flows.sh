#! /bin/bash
simple_switch_CLI --thrift-port 9095 << EOD

table_add MyIngress.swid set_swid  => 6

table_add MyIngress.ipv4_lpm ipv4_forward 10.168.199.80/32 => 34:48:ed:f8:f3:07 1
table_add MyIngress.ipv4_lpm ipv4_forward 10.168.198.81/32 => 34:48:ed:f8:f1:36 3
table_add MyIngress.ipv4_lpm ipv4_forward 10.168.198.82/32 => 34:48:ed:f8:f1:36 3

table_add MyIngress.ipv4_lpm1 ipv4_forward1 10.168.199.80/32 => 34:48:ed:f8:f3:07 1
table_add MyIngress.ipv4_lpm1 ipv4_forward1 10.168.198.81/32 => 34:48:ed:f8:f1:36 3
table_add MyIngress.ipv4_lpm1 ipv4_forward1 10.168.198.82/32 => 34:48:ed:f8:f1:36 3

table_add MyIngress.ipv4_lpm2 ipv4_forward2 10.168.199.80/32 => 34:48:ed:f8:f2:8f 2
table_add MyIngress.ipv4_lpm2 ipv4_forward2 10.168.198.81/32 => 34:48:ed:f8:f1:36 3
table_add MyIngress.ipv4_lpm2 ipv4_forward2 10.168.198.82/32 => 34:48:ed:f8:f1:36 3

EOD
