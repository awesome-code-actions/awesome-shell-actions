find-pid-by-port() {
    port=$1
    netstat -ltnp|grep $port
}

find-port-by-pid() {
    pid=$1
    netstat -ltnp|grep $pid
}

kill-process-by-port() {

}

list-current-ip() {

}