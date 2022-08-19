# action-category: network

find-pid-by-port() {
	port=$1
	netstat -ltnp | grep $port
}

find-port-by-pid() {
	pid=$1
	netstat -ltnp | grep $pid
}

alias which-port-usd-by-pid=find-port-by-pid

kill-process-by-port() {
	port=$1
	lsof -i:${port} | sed -n '2p' | awk '{print $2}' | tr -d '\n' | xargs -i{} kill -9 {}
}

function test-tcp-connect {
	local ip=$1
	local port=$2
	nc -z -v $ip $port
}

function bridge-eyes() {
	local all_bridges=$(ip --json link show type bridge | jq -r '.[].ifname')
	echo "$all_bridges" | while read bridge; do
		echo "show info of bridge $bridge"
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

function bridge-if-show() {
	local ifname=$1
	if echo "$ifname" | grep '^veth' ; then
		veth-show $ifname
		return
	fi
	local eth_type=$(ethtool -i  $ifname |grep 'driver')
	echo "    eth_type $eth_type"
}

function veth-show() {
	# TODO just iter all docker ns
	local veth=$1
	local docker=$(docker-list-veth | grep "$veth")
	echo "  used in docker $docker"
	return
}

function ip-range() {
    ip=$1; mask=$2
    ipcalc "$ip/$mask"
}