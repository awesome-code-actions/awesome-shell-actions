#!/bin/bash

function ebpf-hello-world() {
  sudo bpftrace -v -e 'BEGIN { printf("hello world\n"); }'
}

function ebpf-kprobe-hello() {
  sudo bpftrace -e 'kprobe:ip_vs_reply4 {printf("%s\n",comm);}'
}

function ebpf-on-func-call() {
  set -x
  sudo bpftrace -e "kprobe:$1 {printf(\"call me %s\\n\",probe);}"
  set +x
}

function ebpf-list-all-probe() {
  sudo bpftrace -l
}

function how-many-systemcall-each-cpu() {
  local base=$(dirname $(zmx-find-path-of-action))
  echo $base
  sudo bpftrace $base/syscount-each-cpu.bt
}

function list-symbol-by-file() {
  local p=$1
  objdump -tT $p
}

function ebpf-list-all-uprobe-of-file() {
  local bin_path=$1
  echo bin_path is $bin_path
  sudo bpftrace -lv "uprobe:$bin_path:*" 2>&1
}

function ebpf-ami-btf() {
  cat /boot/config-$(uname -r) | grep BTF
}

function ebpf-dump-btf() {
  bpftool btf dump file $1
}
