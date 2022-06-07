#!/bin/bash

function ebpf-hello-world() {
	sudo bpftrace -v -e 'BEGIN { printf("hello world\n"); }'
}

how-many-systemcall-each-cpu() {
	local base=$(dirname $(zmx-find-path-of-action))
	echo $base
	sudo bpftrace $base/syscount-each-cpu.bt
}

list-symbol-by-file() {
	local p=$1
	objdump -tT $p
}

bpf-list-all-uprobe-of-file() {
	local bin_path=$1
	echo bin_path is $bin_path
	sudo bpftrace -lv "uprobe:$bin_path:*" 2>&1 
}