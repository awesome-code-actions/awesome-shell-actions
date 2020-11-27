#!/bin/bash

enter-into-networknamespace-by-pid-and-run() {
    pid=$1
    cmd=$2
    nsenter -t $pid -n $cmd
}
