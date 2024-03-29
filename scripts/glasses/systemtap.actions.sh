#!/bin/bash

function stap-hello-world() {
  sudo stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
}

function default-or-select-docker-id() {
  local arg=$1
  if [ -z "$arg" ]; then
    echo $(docker ps | tail -n+2 | fzf | awk '{print $1}')
    return
  fi
  echo $arg
  return
}

function stap-connect-docker() {
  local dockerid=$(default-or-select-docker-id $1)
  local base=$(zmx-find-base-of-action)
  local pidns=$(docker-get-pidns-by-id $dockerid)
  echo $pidns
  sudo stap -B CONFIG_MODVERSIONS=y -g -vv $base/connect_stat.stp $pidns
}

function stap-list-all-probele() (
  stap-list-all-kernel-function
  stap-list-all-module-function
)

function stap-list-all-kernel-function {
  stap -L 'kernel.function("*")'
  return
}

function stap-list-all-module-function {
  stap -L 'module("*").function("*")' 2>&1
  return
}
function stap-list-statement {
  stap -L 'kernel.statement("*")'
  stap -L 'kernel.statement("*")'
  return
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

function list-all-kernel-file {
  return
}
