#! /bin/bash
simple_switch_CLI --thrift-port 9096 << EOD

table_add MyIngress.swid set_swid => 1

table_add MyIngress.ipv4_lpm ipv4_forward 10.168.199.80/32 => d8:cb:8a:a6:78:9d 1
table_add MyIngress.ipv4_lpm ipv4_forward 10.168.198.81/32 =>b0:26:28:9c:e3:8d 2

table_add MyIngress.ipv4_lpm1 ipv4_forward1 10.168.199.80/32 => d8:cb:8a:a6:78:9d 1
table_add MyIngress.ipv4_lpm1 ipv4_forward1 10.168.198.81/32 => b0:26:28:9c:e3:8d 2

table_add MyIngress.ipv4_lpm2 ipv4_forward2 10.168.199.80/32 => d8:cb:8a:a6:78:9d 1
table_add MyIngress.ipv4_lpm2 ipv4_forward2 10.168.198.81/32 => b0:26:28:9c:ea:43 3

EOD
