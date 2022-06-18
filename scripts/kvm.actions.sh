#!/bin/bash

function kvm-list-net() {
	for vm in $(virsh list --state-running --name); do echo "$vm: " && virsh domiflist $vm | sed -n "3,$ { s,^,\t,; p }"; done
}

function kvm-list-vm() {
	virsh list --all
}

function kvm-list-host() {
	virsh net-dhcp-leases default
}

function kvm-ssh() {
	local s=$(virsh net-dhcp-leases default  |grep ipv4 |awk '{print($5,$6)}'|fzf)
	echo $s
	local ip=$(echo $s|awk '{print $1}'|cut -d '/' -f 1)
	ssh cong@$ip
}
