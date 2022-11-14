#!/bin/bash

function etcd-dumper-install() {
  go install github.com/woodgear/etcd-dumper@latest
  which etcd-dumper
}

function etcdctl-use-kind() {
  local cluster=$(kind get clusters | fzf)
  local container="$cluster-control-plane"
  echo "container: $container"
  local base=$HOME/.etcdctl
  local cert_dir=$base/etcd
  mkdir -p $base
  echo "$cluster" >$base/cluster
  echo "$container" >$base/container
  echo kubectl port-forward -n kube-system etcd-$cluster-control-plane 2379:2379 --address="0.0.0.0"
  # steal cert
  docker cp $container:/etc/kubernetes/pki/etcd/ $base
  local ep=$(docker-get-ip $container)
  echo "127.0.0.1:2379" >$base/ep
  touch $base/https
  # take a shot
  etcdctl-list-ns
}

function etcdctl-use-vagrant() {
  local base=$HOME/.etcdctl
  local cert_dir=$base/etcd
  mkdir -p $base
  # steal cert

  local cfg=$(vagrant-list | fzf)
  local name=$(echo $cfg | awk '{print $1}')
  local ip=$(echo $cfg | awk '{print $2}')
  echo $name $ip
  echo "$ip:2379" >$base/ep
  scp -r root@$ip:/etc/kubernetes/pki/etcd/ $base
  touch $base/https
  # take a shot
  etcdctl-list-ns
}

function etcdctl-use-http() {
  local url=$1
  local base=$HOME/.etcdctl
  rm -rf $base/https
  echo "$1" >$base/ep
  touch $base/http
}

function etcdctl-list-ns() {
  etcdctl-get-dumper "/registry/namespaces" | yq '.kvs[].key'
}

function etcdctl-list-all-key() {
  etcdctl-get-raw / | jq -r '.kvs|=map(.key|=@base64d) | .kvs[].key'
}

function etcdctl-peek-a-key() {
  local key=$(etcdctl-list-all-key | fzf)
  etcdctl-get-dumper "$key"
}

function etcdctl-get() {
  etcdctl-get-dumper $1
}

function etcdctl-get-raw() {
  local get="$1"
  local base=$HOME/.etcdctl
  local cert_dir=$base/etcd
  local cert_opt=""
  if [ -f "$base/https" ]; then
    cert_opt="--cacert=$cert_dir/ca.crt --cert=$cert_dir/peer.crt --key=$cert_dir/peer.key"
  fi
  local ep=$(cat $base/ep)
  local cmd="ETCDCTL_API=3 etcdctl $cert_opt --endpoints=$ep  get $get --prefix -w=json|python3 -m json.tool > $base/out.json"
  eval "$cmd"
  cat $base/out.json
}

function etcdctl-do() {
  local get="$1"
  local base=$HOME/.etcdctl
  local cert_dir=$base/etcd
  local cert_opt=""
  if [ -f "$base/https" ]; then
    cert_opt="--cacert=$cert_dir/ca.crt --cert=$cert_dir/peer.crt --key=$cert_dir/peer.key"
  fi
  local ep=$(cat $base/ep)
  local cmd="ETCDCTL_API=3 etcdctl $cert_opt --endpoints=$ep $@"
  eval "$cmd"
}

function etcdctl-do-cmpact() {
  local version=$(etcdctl-do endpoint status --write-out=json | jq '.[0].Status.header.revision')
  etcdctl-do compact $version
}

function etcdctl-get-dumper() {
  local base=$HOME/.etcdctl
  rm -f $base/out.json
  etcdctl-get-raw $1 >$base/out.json
  etcd-dumper $base/out.json
}

function etcdctl-get-raw-debase64() {
  local key="$1"
  etcdctl-get-raw $key | jq -r '.kvs|=map(.key|=@base64d) | .kvs|=map(.value|=@base64d)'
}
