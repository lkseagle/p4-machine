#!/bin/bash
for pid in `sudo ps -aux | grep thrift-port | grep -v "grep"| awk '{print $2}'`
do
    sudo kill -9 ${pid} &>/dev/null
done

