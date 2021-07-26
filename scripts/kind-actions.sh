
function _prepare_kind_cluster_config() {
	file=${1:-"/tmp/cluster.yaml"}
	echo $file
cat > $file <<EOL
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
kubeadmConfigPatches:
- |
  apiVersion: kubeadm.k8s.io/v1beta2
  kind: ClusterConfiguration
  metadata:
    name: config
  apiServer:
    extraArgs:
      "feature-gates": "EphemeralContainers=true"
  scheduler:
    extraArgs:
      "feature-gates": "EphemeralContainers=true"
  controllerManager:
    extraArgs:
      "feature-gates": "EphemeralContainers=true"
- |
  apiVersion: kubeproxy.config.k8s.io/v1alpha1
  kind: KubeProxyConfiguration
  conntrack:
    maxPerCore: 0
- |
  apiVersion: kubeadm.k8s.io/v1beta2
  kind: InitConfiguration
  metadata:
    name: config
  nodeRegistration:
    kubeletExtraArgs:
      "feature-gates": "EphemeralContainers=true"
nodes:
- role: control-plane
EOL
}

function kind-create-1.16.5() {
	_prepare_kind_cluster_config /tmp/cluster.yaml
	kind create cluster  --config /tmp/cluster.yaml --name k-16-15 --image=kindest/node:v1.16.15
}

function kind-create-20() {
	_prepare_kind_cluster_config /tmp/cluster.yaml
	kind create cluster --config /tmp/cluster.yaml --name k-16-2 --image=kindest/node:v1.16.15
}

function default-cluster-config() {
	p=/${RANDOM:0:2}
}

function kind-delete() {
	kind delete cluster --name $(kind get clusters |fzf --prompt="select cluster you want to delete")
}

function kind-list-image() {
	# category: glasses
	dockerhub-list-tags kindest/node
}

function kind-load-image() {
	# arg-len: 1
	local image=$1
	docker pull $image
	kind load docker-image $image --name $(kind get clusters |fzf --prompt="select cluster you image load for")
}