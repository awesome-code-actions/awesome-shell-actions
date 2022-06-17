#!/bin/bash

function kvm-list-net() {
	for vm in $(virsh list --state-running --name); do echo "$vm: " && virsh domiflist $vm | sed -n "3,$ { s,^,\t,; p }"; done
}

function kvm-list-host() {
	virsh net-dhcp-leases default
}

function kvm-ssh() {
	virsh net-dhcp-leases default  |grep ipv4 | awk '{print $5}'|cut -d '/' -f 1
}