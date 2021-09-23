#!/bin/bash

ns-enter-all-by-pid-and-run() {
    # @arg-len: 2
    pid=$1
    cmd=$2
    sudo nsenter -a -t $pid -n $cmd
}


ns-list-all-by-pid() {
    # category: glasses
}