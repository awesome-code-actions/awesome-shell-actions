function install-vela() {
	helm repo add kubevela https://kubevelacharts.oss-accelerate.aliyuncs.com/core
	helm repo update
	helm install --create-namespace -n vela-system kubevela kubevela/vela-core
}