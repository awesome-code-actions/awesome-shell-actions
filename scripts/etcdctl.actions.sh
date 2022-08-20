#!/bin/bash

function etcdctl-use-kind() {
    local cluster=$(kind get clusters | fzf)
    local container="$cluster-control-plane"
    echo "container: $container"
    local base=$HOME/.etcdctl
    local cert_dir=$base/etcd
    mkdir -p $base
    echo "$cluster" >$base/cluster
    echo "$container" >$base/container
    # steal cert
    docker cp $container:/etc/kubernetes/pki/etcd/ $base
    local ep=$(docker-get-ip $container)
    echo "$ep" >$base/ep

    # take a shot
    etcdctl-list-ns
}

function etcdctl-list-ns() {
    etcdctl-get "/registry/namespaces" | jq -r '.kvs[].key'
}

function etcdctl-get() {
    etcdctl-get-raw $1 | jq -r '.kvs|=map(.key|=@base64d) | .kvs|=map(.value|=@base64d)'
}

function etcdctl-get-raw() {
    local get="$1"
    local base=$HOME/.etcdctl
    local cert_dir=$base/etcd
    local cert_opt="--cacert=$cert_dir/ca.crt --cert=$cert_dir/peer.crt --key=$cert_dir/peer.key"
    local ep=$(cat $base/ep)
    local cmd="ETCDCTL_API=3 etcdctl $cert_opt --endpoints=$ep:2379  get $get --prefix -w=json|python3 -m json.tool > $base/out.json"
    eval "$cmd"
    cat $base/out.json
}

function etcdctl-list-all-key() {
    etcdctl-get "/" | jq -r '.kvs[].key'
}
