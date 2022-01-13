apt-list-all-repo() {
	grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/*
}

apt-check-proxy() {
	cat /etc/apt/apt.conf.d/proxy.conf
}

apt-update() {
	sudo apt update
}