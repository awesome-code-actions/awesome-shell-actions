function _prepare_kind_cluster_config() {
  file=${1:-"/tmp/cluster.yaml"}
  echo $file
  cat >$file <<EOL
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: ipv4
  apiServerAddress: "127.0.0.1"
nodes:
- role: control-plane
EOL
}

function kind-create-1.16.5() {
  local name=${1:-"k-1-19-11"}
  _prepare_kind_cluster_config /tmp/cluster.yaml
  kind create cluster --config /tmp/cluster.yaml --name $name --image=kindest/node:v1.16.15
}

function kind-create-1.19.11() {
  local name=${1:-"k-1-19-11"}
  _prepare_kind_cluster_config /tmp/cluster.yaml
  kind create cluster --config /tmp/cluster.yaml --name $name --image=kindest/node:v1.19.11
}

function kind-create-1.21.1() {
  local name=${1:-"k-1-21-1"}
  _prepare_kind_cluster_config /tmp/cluster.yaml
  kind create cluster --config /tmp/cluster.yaml --name $name --image=kindest/node:v1.21.1
}

function kind-create-1.24.3() {
  local name=${1:-"k-1-24-3"}
  _prepare_kind_cluster_config /tmp/cluster.yaml
  kind create cluster --config /tmp/cluster.yaml --name $name --image=kindest/node:v1.24.3
}

function default-cluster-config() {
  p=/${RANDOM:0:2}
}

function kind-delete() {
  kind delete cluster --name $(kind get clusters | fzf --prompt="select cluster you want to delete")
}

function kind-list() {
  kind get clusters
}

function kind-delete-all() {
  kind get clusters | xargs -I{} kind delete cluster --name {}
}

function kind-list-image() {
  # category: glasses
  dockerhub-list-tags kindest/node
}

function kind-load-image() {
  # @arg-len: 1
  local image=$1
  local cluster=$2
  if [ -z "$cluster" ]; then
    cluster=$(kind get clusters | fzf)
  fi

  docker pull $image
  kind load docker-image $image --name $cluster
}

function kind-source-kubeconfig() {
  # @arg-len: 1
  # @fzf

  local cluster=$1
  if [ -z "$cluster" ]; then
    cluster=$(kind get clusters | fzf)
  fi
  kind get kubeconfig --name=$cluster >~/.kube/$cluster
  local ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $cluster-control-plane)
  echo $cluster $ip
  export KUBECONFIG=~/.kube/$cluster
  cat $KUBECONFIG | grep server
  sed -i "s|server.*|server: https://$ip:6443|g" ~/.kube/$cluster
  echo $KUBECONFIG
}
