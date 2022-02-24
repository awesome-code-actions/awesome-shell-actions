go-test-all() {
    go test -v ./...
}

go-use-china-proxy() {
    go env -w GOPROXY=https://goproxy.cn,direct
}

go-unset-go-proxy() {
    unset GOPROXY
}

go-list-test() {
    local list=$(go test ./...  -list=. |grep -v '?')
	export LIST=$list
	local output=$( bash <<-EOF
	python3 - <<-START
		import os
		list = os.environ["LIST"]
		map = {}
		for l in list.splitlines()
			if l.startswith("ok")
				map[]
		print(list)
	START
	EOF
	)
    echo $output

    return
}