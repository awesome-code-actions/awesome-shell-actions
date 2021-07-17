find-pid-by-port() {
    port=$1
    netstat -ltnp|grep $port
}

find-port-by-pid() {
    pid=$1
    netstat -ltnp|grep $pid
}

alias which-port-usd-by-pid=find-port-by-pid

kill-process-by-port() {
   port=$1
   lsof -i:${port}|sed -n '2p'|awk '{print $2}' |tr -d '\n'|xargs -i{} kill -9 {}
}

list-current-ip() {

}
