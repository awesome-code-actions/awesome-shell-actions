#!/bin/bash

function py-allow-break-package() (
  sudo rm /usr/lib/python3.*/EXTERNALLY-MANAGED
)

function py-list-installed() (
  pip list --format=columns
)

function py-china-proxy() (
  local cfg=$(
    cat <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF
  )
  mkdir -p ~/.pip
  echo "$cfg" >~/.pip/pip.conf
)
