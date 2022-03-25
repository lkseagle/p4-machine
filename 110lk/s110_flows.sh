#! /bin/bash
simple_switch_CLI --thrift-port 9093 << EOD

table_add MyIngress.swid set_swid => 4

table_add MyIngress.ipv4_lpm ipv4_forward 10.168.199.80/32 => b0:26:28:9c:e2:e3 1

table_add MyIngress.ipv4_lpm1 ipv4_forward1 10.168.199.80/32 => b0:26:28:9c:e2:e3 1
table_add MyIngress.ipv4_lpm1 ipv4_forward1 10.168.198.81/32 => d8:cb:8a:a6:79:24 3



table_add MyIngress.ipv4_lpm2 ipv4_forward2 10.168.199.80/32 => b0:26:28:9c:e2:e3 1
table_add MyIngress.ipv4_lpm2 ipv4_forward2 10.168.198.81/32 => d8:cb:8a:a6:79:24 3


EOD
