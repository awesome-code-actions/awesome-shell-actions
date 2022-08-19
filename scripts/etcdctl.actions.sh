#!/bin/bash

function etcdctl-use-kind() {
    set -x
    local cluster="k-1-24-3"
    # local cluster=$( kind get clusters |fzf)
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

#etcdctl-list-ns |jq -r '.kvs[].key'
function etcdctl-list-ns() {
    etcdctl-get "/registry/namespaces"
}

function etcdctl-get() {

    local get="$1"
    local base=$HOME/.etcdctl
    local cert_dir=$base/etcd
    local cert_opt="--cacert=$cert_dir/ca.crt --cert=$cert_dir/peer.crt --key=$cert_dir/peer.key"
    local ep=$(cat $base/ep)
    local cmd="ETCDCTL_API=3 etcdctl $cert_opt --endpoints=$ep:2379  get $get --prefix -w=json|python3 -m json.tool > $base/out.json"
    eval "$cmd"
    jq -r '.kvs|=map(.key|=@base64d) | .kvs|=map(.value|=@base64d)' <$base/out.json
}

function etcdctl-list-all-key() {
    etcdctl-get "/" | jq -r '.kvs[].key'
}
