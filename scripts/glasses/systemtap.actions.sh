#!/bin/bash

stap-hello-world() {
	sudo stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
}

function list-all-syscall {
	return
}

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