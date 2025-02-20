#!/bin/bash

function docker-kill-and-drop-container-by-regex() {
  regex=$1
  docker ps --format "{{.Names}}" | grep $regex | xargs -I {} sh -c 'docker stop {} && docker rm {}'
}

function docker-get-pid-by-container-name-or-uuid() {
  id=$1
  docker inspect -f '{{.State.Pid}}' $id
}

function docker-get-networknamespace-by-container-name-or-uuid() {
  id=$1
  container_pid=$(docker-get-pid-by-container-name-or-uuid $id)
  sudo ls -l /proc/$container_pid/ns/net
}

function docker-set-mirror() {
  mirror=$1
  FILE=/etc/docker/daemon.json
  sudo mkdir -p /etc/docker
  sudo jq -n --arg mirror $mirror '{"registry-mirrors":["\($mirror)"]}' | sudo tee $FILE
  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

function docker-get-proxy() {
  cat /etc/systemd/system/docker.service.d/http-proxy.conf
}
# require: jq
function docker-get-mirror() {
  cat /etc/docker/daemon.json | jq '.["registry-mirrors"]'
}

function docker-export-x86-image-to-dir() {
  # @arg-len: 2
  image=$1
  docker pull $image
  name=$(echo $image | cut -d '/' -f 3 | tr -d '\n\r')
  echo $nam
  mkdir -p $name
  cd ./$name
  # docker save $image --output $name.tar
  # tar xvf ./$name.tar
  # rm ./$name.tar
  # find |grep  .tar |xargs -i{} tar xvf {}
  # set +e
}

function docker-pull-arm() {
  # @arg-len: 1
  # @arg1: image no-empty-string
  image=$1
  docker-pull-with-platform $image
}

function docker-pull-with-platform() {
  # @arg-len: 2
  # @arg1: image no-empty-string
  # @arg2: platform no-empty-string

  local image=$1
  local platform=$2
  echo $image $platform
  dig=$(docker manifest inspect $image | jq -r ".manifests[] | select(.platform.architecture==\"$platform\")|.digest")
  full_image=$image@$dig
  docker pull $full_image
}

function docker-exec() {
  docker exec -it $(docker ps | fzf --prompt="select docker you want to exec" | awk '{print $1}') sh
}

function docker-select-id() {
  docker ps | tail -n+2 | fzf --prompt="select a docker" | awk '{print $1}' | tr -d '\n\r'
}

function docker-get-pid-by-id() {
  local id=$1
  docker inspect $id | jq '.[0].State.Pid'
}

function docker-get-pidns-by-id() {
  local id=$1
  local pid=$(docker-get-pid-by-id $id)
  sudo ls -alh /proc/$pid/ns/pid | rg -o '\[(.*)\]' -r '$1'
}

function docker-get-name-by-id() {
  local id=$1
  docker inspect $id | jq '.[0].Name'
}

function docker-delte() {
  docker ps | tail -n+2 | fzf -m --prompt="select docker you want to kill(tab to mutli select)" | awk '{print $1}' | xargs -i{} docker rm -f {}
}

function docker-list-ip() {
  docker ps | tail -n+2 | awk '{print $1}' | xargs -I{} sh -c "echo '{} ' |tr -d '\n\r' &&  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' {} | tr -d '\n\r' &&echo -n ' ' && docker inspect -f '{{.Name}}' {}"
}

function docker-get-ip() {
  local c=$1
  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $c
}

function docker-install-buildx() {
  mkdir -p ~/.docker/cli-plugins/
  curl -L https://github.com/docker/buildx/releases/download/v0.7.1/buildx-v0.7.1.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
  chmod +x ~/.docker/cli-plugins/docker-buildx
  # edit config
  jq . ~/.docker/config.json
  cp ~/.docker/config.json ~/.docker/config.json.bak
  cat <<<$(jq '.experimental="enable"' ~/.docker/config.json) >~/.docker/config.json
  jq . ~/.docker/config.json
  if ! echo $PATH | grep -q 'docker/cli-plugin'; then
    echo "YOU MUST PUT  ~/.docker/cli-plugins IN YOUR PATH"
  fi
  docker buildx version
}

function docker-eyes() {
  local id=$(docker-select-id)
  echo id $id
  local name=$(docker-get-name-by-id $id)
  local pid=$(docker-get-pid-by-id $id)

  echo "name:" $name
  echo "pid:" $pid

  echo "veth in docker: " $(sudo nsenter -t $pid -n ip addr show | grep eth0)
  local vethid=$(sudo nsenter -t $pid -n ip addr show | grep eth0 | python -c 'import sys;print(sys.stdin.readlines()[0].split(" ")[1].split("@if")[1].split(":")[0])')
  echo "vethid $vethid"
  echo "veth in host:" $(ip link | grep "$vethid: ")
}

function docker-save() {
  local image=$1
  local tar=$(echo $image | sed 's/\//_/g')
  echo "$tar"
  docker save "$image" -o "$tar.docker.image.tar"
}
function docker-mems {
  numfmt --field=2 --from-unit=1024 --to=iec-i --suffix B </proc/meminfo | sed 's/ kB//'
  numfmt --field=2 --from-unit=1024 --to=iec-i --suffix B </sys/fs/cgroup/memory/memory.stat | sed 's/ kB//'
}

function docker-build-with-proxy {
  set -x
  if [ -n "$HTTP_PROXY" ]; then
    arg="--build-arg https_proxy=$HTTP_PROXY --build-arg http_proxy=$HTTP_PROXY --network=host"
  fi
  local cmd="docker build $arg $@"
  eval $cmd
}

function docker-image-exist {
  # TODO
  return
}

function docker-pull-if-not-exist {
  # TODO
  local image=$1
  if [[ $(docker-image-exist $image) == "true" ]]; then
    echo "$image exist"
    return
  fi
  docker pull $image
}

function docker-ps-via-id() (
  local id=${1-$(docker-select-id)}
  local pid_of_container=$(docker inspect $id | jq '.[0].State.Pid')
  local pidns=$(sudo sh -c "ls -l /proc/$pid_of_container/ns/pid|grep -o '\[.*\]'|tr -d '[]'")
  while read pid; do
    local pid_info_in_host=$(ps -o pid,uid,cmd -p $pid --no-headers)
    local pid_in_ns=$(cat /proc/$pid/status | grep NSpid | awk '{print $3}')
    echo $pid_in_ns $pid_info_in_host
  done < <(sudo sh -c "ls -l /proc/*/ns/pid|grep $pidns | awk '{print \$9}'| awk -F'/' '{print \$3}'")
)

function ps-with-container() {
  local filter="$1"
  declare -A pid_cinfo_m
  declare -A cid_pid_m
  declare -A pid_pidns_m
  declare -A pidns_cid_m
  declare -A cid_inspect_m
  while read cinfo; do
    local cid=$(echo "$cinfo" | awk '{print $1}')
    local cid_inspect=$(crictl inspect $cid | jq -c '{pod: .status.labels."io.kubernetes.pod.name",pid: .info.pid,container: .info.config.metadata.name}' | tr -d '\n')
    local pid=$(echo "$cid_inspect" | jq '.pid')
    cid_inspect_m["$cid"]="$cid_inspect"
    cid_pid_m["$cid"]=$pid
    pid_cinfo_m["$pid"]=$pid
    if [ ! -e /proc/$pid ]; then
      continue
    fi
    local pidns=$(ls -l /proc/$pid/ns/pid | grep -o '\[.*\]' | tr -d '[]')
    pid_pidns_m[$pid]=$pidns
    pidns_cid_m[$pidns]=$cid
  done < <(crictl ps | tail -n+2)

  while read pinfo; do
    local pid=$(echo "$pinfo" | awk '{print $2}')
    if [ ! -e /proc/$pid ]; then
      continue
    fi
    local pidns=$(ls -l /proc/$pid/ns/pid | grep -o '\[.*\]' | tr -d '[]')
    echo "$pid $pidns"

    local pid_in_ns=$(cat /proc/$pid/status | grep NSpid | awk '{print $3}')
    if [[ -z "$pid_in_ns" ]]; then
      echo "- $pinfo"
      continue
    fi
    local container=""

    if [[ ! -v "pidns_cid_m[$pidns]" ]]; then
      echo "- $pinfo"
      continue
    fi
    local cid="${pidns_cid_m[$pidns]}"
    local pid_in_ns=$(cat /proc/$pid/status | grep NSpid | awk '{print $3}')
    local cinspect=${cid_inspect_m[$cid]}
    local name=$(echo "$cinspect" | jq -r '.container')
    local pod=$(echo "$cinspect" | jq -r '.pod')
    echo "* $pod $name $cid $pid $pid_in_ns $pinfo"
  done < <(ps -aux --no-headers | grep "$filter")
}

function docker-purge() (
  docker system prune
)
