#!/bin/bash

function apt-list-all-repo() {
	grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/*
}

function apt-check-proxy() {
	cat /etc/apt/apt.conf.d/proxy.conf
}

function apt-unset-proxy() {
    sudo rm /etc/apt/apt.conf.d/proxy.conf
}

function apt-set-proxy() {
    local proxy=$(cat << EOF
Acquire {
  HTTP::proxy "http://127.0.0.1:20172";
  HTTPS::proxy "http://127.0.0.1:20172";
}
EOF
    )
    echo "$proxy" | sudo tee /etc/apt/apt.conf.d/proxy.conf
}

function apt-update() {
	sudo apt update
}