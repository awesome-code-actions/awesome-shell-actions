go-test-all() {
    go test -v ./...
}

go-use-china-proxy() {
    go env -w GOPROXY=https://goproxy.cn,direct
}