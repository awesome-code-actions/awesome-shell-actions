#!/usr/bin/env bash

function go-test-all() {
  go test -v ./...
}

function go-use-china-proxy() {
  go env -w GOPROXY=https://goproxy.cn,direct
}

function go-unset-go-proxy() {
  unset GOPROXY
}

function go-run-one-test() {
  local test=$(go-list-test | fzf)
  local t=$(echo $test | cut -f1 -d' ')
  local p=$(echo $test | cut -f2 -d' ')
  echo "$t" "$p"
  add-history go test -v -run "$t" "$p"
  go test -v -run "$t" "$p"

}

function go-list-test() {
  local testlist=$(go test ./... -list=. | grep -v '?')
  exec 3<<<"$testlist"
  python3 - <<-'START'
	import sys
	import os
	data=os.read(3,10240).decode("utf-8")
	m = {}
	temp = []
	for line in data.split('\n'):
    	if line.startswith('ok'):
        	package = line.split()[1]
        	m[package] = temp
        	temp = []
        	continue
    	temp.append(line)
	for p, ts in m.items():
    	for t in ts:
        	print("go test -v -run ",t, p)
	START
}

function go-static-build() (
  rm ./main && CC=/usr/bin/musl-gcc CGO_ENABLED=1 go build -v -ldflags '-linkmode=external -extldflags=-static' -v main.go && ldd ./main
)

function go-pprof-cpu-flamegraph() (
  local url=$1
  go tool pprof -raw -output=cpu.txt "$url/profile?seconds=20"

)
