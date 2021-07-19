function kind-create-20() {
	kind create cluster --name k-16-2 --image=kindest/node:v1.16.15
}

function kind-create-1.16.5() {
	kind create cluster --name k-16-2 --image=kindest/node:v1.16.15
}

function default-cluster-config() {
	p=/${RANDOM:0:2}
}

function kind-delete() {
	kind delete cluster --name $(kind get clusters |fzf --prompt="select cluster you want to delete")
}

function kind-list-image() {
	dockerhub-list-tags kindest/node
}
