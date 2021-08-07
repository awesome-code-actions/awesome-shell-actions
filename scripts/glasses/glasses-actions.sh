how-many-systemcall-each-cpu() {
	CFD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	sudo bpftrace $CFD/syscount-each-cpu.bt
}