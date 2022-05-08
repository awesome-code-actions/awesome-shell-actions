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
	local veths=$(ip --json link show master $b | jq -r '.[].ifname')
	echo "$veths" | while read veth; do
		if [ -z "$veth" ]; then
			continue
		fi
		echo "  show info of veth $veth"
		veth-show $veth
	done
}

function veth-show() {
	# TODO
	local veth=$1
	local vethinfo=$(ip link show dev $veth)
	echo "    $vethinfo"
	return
}