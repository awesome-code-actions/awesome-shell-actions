#!/bin/bash
errcho() { echo >&2 $@; }

function etcdctl-init() {
    # you need go etcdctl jq
  go install github.com/woodgear/etcd-dumper@latest
  which etcd-dumper
  yum install etcdclient
}

function etcdctl-use-local-k8s() {
  local base=$HOME/.etcdctl
  mkdir -p $base
  cp -r /etcd/kubernetes/pki/etcd $base
  echo "127.0.0.1:2379" >$base/ep
  touch $base/https
  etcdctl-list-ns
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
  #   echo "127.0.0.1:2379" >$base/ep
  errcho "ep is $ep"
  echo "$ep:2379" >$base/ep
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
  etcdctl-get-dumper "/registry/namespaces --keys-only" | yq '.kvs[].key'
}

function etcdctl-list-all-key() {
  etcdctl-get-raw-json-show / --keys-only | jq -r '.kvs|=map(.key|=@base64d) | .kvs[].key'
}

function etcdctl-peek-a-key() {
  local key=$(etcdctl-list-all-key | fzf)
  etcdctl-get-dumper "$key"
}


function etcdctl-get() {
  etcdctl-get-dumper $1
}

function etcdctl-get-raw-json-show() {
  etcdctl-get-raw-json $@
  local base=$HOME/.etcdctl
  cat $base/out.json
}

function etcdctl-get-raw-json() {
  local get="$@"
  local base=$HOME/.etcdctl
  local cert_dir=$base/etcd
  local cert_opt=""
  if [ -d $cert_dir ]; then
    # echo "https://127.0.0.1:2379" >$base/ep
    cert_opt="--cacert=$cert_dir/ca.crt --cert=$cert_dir/peer.crt --key=$cert_dir/peer.key"
  fi
  local ep=$(cat $base/ep)
  #   local cmd="ETCDCTL_API=3 etcdctl $cert_opt --endpoints=$ep  get $get --prefix -w=json|python3 -m json.tool > $base/out.json"
  local cmd="ETCDCTL_API=3 etcdctl $cert_opt --endpoints=$ep  get $get --prefix -w=json|jq . > $base/out.json"
  errcho "$cmd"
  eval "$cmd"
}

function etcdctl-get-raw-yaml() {
  local get="$@"
  local base=$HOME/.etcdctl
  local cert_dir=$base/etcd
  local cert_opt=""
  if [ -d $cert_dir ]; then
    cert_opt="--cacert=$cert_dir/ca.crt --cert=$cert_dir/peer.crt --key=$cert_dir/peer.key"
  fi
  local ep=$(cat $base/ep)
  local cmd="ETCDCTL_API=3 etcdctl $cert_opt --endpoints=$ep  get $get --prefix -w=yaml |yq . > $base/out.yaml"
  errcho "$cmd"
  eval "$cmd"
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
  etcdctl-get-raw-json $@
  etcd-dumper $base/out.json
}

function etcdctl-get-raw-json-debase64() {
  local key="$1"
  etcdctl-get-raw-json $key
  jq -r '.kvs|=map(.key|=@base64d) | .kvs|=map(.value|=@base64d)' ~/.etcdctl/out.json
}
