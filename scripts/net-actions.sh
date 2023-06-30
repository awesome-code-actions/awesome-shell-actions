#!/usr/bin/env bash
# action-category: network

function find-pid-by-port() {
  port=$1
  netstat -ltnp | grep $port
}

function find-port-by-pid() {
  pid=$1
  netstat -ltnp | grep $pid
}

function kill-process-by-port() {
  port=$1
  lsof -i:${port} | sed -n '2p' | awk '{print $2}' | tr -d '\n' | xargs -i{} kill -9 {}
}

function test-tcp-connect {
  local ip=$1
  local port=$2
  nc -z -v $ip $port
}

function docker-bridge-info() (
  local name=$1
  if [[ "$name" == "docker0" ]]; then
    echo "(default docker bridge)"
    return
  fi
  if echo "$name" | grep -q 'br-'; then
    local id=$(echo $name | awk -F '-' '{print $2}')
    local network=$(docker network ls | grep $id | awk '{print $2}')
    echo "(docker bridge $network)"
    return
  fi
)

function bridge-eyes() {
  local all_bridges=$(ip --json link show type bridge | jq -r '.[].ifname')
  echo "$all_bridges" | while read bridge; do
    local docker_bridge_info=$(docker-bridge-info $bridge)
    echo "show info of bridge $bridge $docker_bridge_info"
    bridge-show $bridge
  done
  return
}

function bridge-show() {
  local b=$1
  local ifnames=$(ip --json link show master $b | jq -r '.[].ifname')
  echo "$ifnames" | while read ifname; do
    if [ -z "$ifname" ]; then
      continue
    fi
    echo "  show info of $ifname"
    bridge-if-show $ifname
  done
}

function bridge-if-show() {
  local ifname=$1
  if echo "$ifname" | grep -q '^veth'; then
    veth-show $ifname
    return
  fi
  local eth_type=$(ethtool -i $ifname | grep 'driver')
  echo "    eth_type $eth_type"
}

function docker-list-veth() {
  local containers=$(docker ps --format '{{.Names}}')
  echo "$containers" | while read dk; do
    local pid=$(docker inspect --format '{{.State.Pid}}' "$dk")
    local ifindex=$(sudo nsenter -t $pid -n ip link | sed -n -e 's/.*eth0@if\([0-9]*\):.*/\1/p')
    if [ -z "$ifindex" ]; then
      veth="not found"
    else
      veth=$(ip -o link | grep ^$ifindex | sed -n -e 's/.*\(veth[[:alnum:]]*@if[[:digit:]]*\).*/\1/p')
    fi
    echo $veth $dk
  done
}

function docker-find-veth() {
  local veth_id=$1
  local containers=$(docker ps --format '{{.Names}}')
  echo "$containers" | while read dk; do
    local pid=$(docker inspect --format '{{.State.Pid}}' "$dk")
    local ifindex=$(sudo nsenter -t $pid -n ip link | sed -n -e 's/.*eth0@if\([0-9]*\):.*/\1/p')
    if [ -z "$ifindex" ]; then
      veth="not found"
    else
      veth=$(ip -o link | grep ^$ifindex | sed -n -e 's/.*\(veth[[:alnum:]]*@if[[:digit:]]*\).*/\1/p')
    fi
    if echo "$veth" | grep -q "$veth_id"; then
      echo $veth $dk
    fi
  done
}

function veth-show() {
  # TODO just iter all docker ns
  local veth=$1
  local docker=$(docker-list-veth | grep "$veth")
  echo "    used in docker $docker"
  return
}

function route-show() {
  local routes=$(route -n | tail -n +3 | awk '{print $1,$2,$3,$8}')
  local output=$(
    bash <<-EOF
python3 - <<-START
import ipcalc
routes="""
$routes
"""
net={}
for route in  routes.splitlines():
    if route.strip()=="":
        continue
    dest,gateway,mask,iface = route.split(" ")
    subnet=ipcalc.Network(dest,mask)
    net[route]={"subnet":subnet,"dest":dest,"gateway":gateway,"mask":mask,"iface":iface}

for routei,neti in  net.items():
    subneti=neti["subnet"]
    desti=neti["dest"]
    print("xx",desti,subneti.host_first(),subneti.host_last())
    pass
for routei,neti in  net.items():
    for routej,netj in  net.items():
        if routei==routej:
            continue
        subneti=neti["subnet"]
        desti=neti["dest"]
        subnetj=netj["subnet"]
        destj=netj["dest"]
        if subneti.host_first()>= subnetj.host_first() and subneti.host_first()<= subnetj.host_last():
            print("coll",routei,routej)
            continue
        pass
        if subneti.host_last()>= subnetj.host_first() and subneti.host_last()<= subnetj.host_last():
            print("coll",routei,routej)
            continue
        pass
    pass
START
	EOF
  )
  echo $output
}

function ip-range() {
  ip=$1
  mask=$2
  if [ -z "$mask" ]; then
    ipcalc "$ip"
  else
    ipcalc "$ip/$mask"
  fi
}

# scan unused ip
function find-free-ip() {
  sudo nmap -v -sn -n $1 -oG - | awk '/Status: Down/{print $2}'
}
