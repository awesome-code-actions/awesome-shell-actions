#!/bin/bash

function ipset-create() {
  sudo ipset create $1 hash:net maxelem 1000000
}

function ipset-rm() {
  #   sudo ipset destroy localnet || true
  sudo ipset destroy $1 || true
}

function ipset-add-net() {
  #   sudo ipset add localnet 10.0.0.0/8
  sudo ipset add $1 $2
}

function ipset-rm-net() {
  #   sudo ipset del localnet 10.0.0.0/8
  sudo ipset del $1 $2
}

function ipset-test() {
  #   sudo ipset test localnet 10.0.0.0/8
  sudo ipset test $1 $2
}
