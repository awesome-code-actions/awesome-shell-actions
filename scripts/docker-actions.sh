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

docker-set-mirror() {
    mirror=$1
    FILE=/etc/docker/daemon.json
    sudo mkdir -p /etc/docker
    sudo jq -n --arg mirror $mirror '{"registry-mirrors":["\($mirror)"]}' |sudo tee $FILE 
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}

# require: jq
docker-get-mirror() {
cat /etc/docker/daemon.json |jq '.["registry-mirrors"]'
}