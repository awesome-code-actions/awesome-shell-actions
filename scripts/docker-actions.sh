#!/bin/bash

docker-kill-and-drop-container-by-regex() {
    regex=$1
    docker ps --format "{{.Names}}" |grep $regex |xargs -I {} sh -c 'docker stop {} && docker rm {}'
}

docker-get-pid-by-container-name-or-uuid() {
    id=$1
    docker inspect -f '{{.State.Pid}}' $id
}

docker-get-networknamespace-by-container-name-or-uuid() {
    id=$1
    container_pid=$(docker-get-pid-by-container-name-or-uuid $id)
    sudo ls -l /proc/$container_pid/ns/net
}

