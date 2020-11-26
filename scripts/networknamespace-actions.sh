#!/bin/bash

enter-into-networknamespace-by-pid-with-shell() {
    pid=$1
    shell=$2
    nsenter -t $pid -n $shell
}
