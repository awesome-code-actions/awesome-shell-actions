#!/bin/bash

stap-hello-world() {
	sudo stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
}

default-or-select-docker-id() {
	local arg=$1
	if [ -z "$arg" ]; then
		echo $(docker ps | tail -n+2 | fzf | awk '{print $1}')
		return
	fi
	echo $arg
	return
}

stap-connect-docker() {
	local dockerid=$(default-or-select-docker-id $1)
	local base=$(zmx-find-base-of-action)
	local pidns=$(docker-get-pidns-by-id $dockerid)
	echo $pidns
	sudo stap -B CONFIG_MODVERSIONS=y -g -vv $base/connect_stat.stp $pidns
}

function list-all-syscall() (
	return
)

function list-all-module {
	return
}

function list-all-vfs-file-operation {
	return
}

function list-all-trace {
	return
}

function list-all-module-function {
	return
}

function list-all-kernel-file {
	return
}
