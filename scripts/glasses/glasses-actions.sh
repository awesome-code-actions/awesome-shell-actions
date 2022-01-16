how-many-systemcall-each-cpu() {
	CFD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	sudo bpftrace $CFD/syscount-each-cpu.bt
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