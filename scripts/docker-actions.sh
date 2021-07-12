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


docker-export-image-to-dir() {
    image=$1
    docker pull $image
    name=$(echo $image | cut -d '/' -f 3 | tr -d '\n\r')
    mkdir $name
    cd $name
    docker save $image --output $name.tar
    tar xvf ./$name.tar
    rm ./$name.tar 
    find |grep  .tar |xargs -i{} tar xvf {}
}

docker-pull-arm() {
    # arg-len: 1
    # arg: image no-empty-string
    image=$1
    docker-pull-with-platform $image 
}

docker-pull-with-platform() {
    # arg-len: 2
    # arg: image no-empty-string
    # arg: platform no-empty-string
    image=$1
    platform=$2
    echo $image $platform
}