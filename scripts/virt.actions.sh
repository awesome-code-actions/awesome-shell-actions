#!/bin/bash

function virt-list-net() {
	for vm in $(virsh list --state-running --name); do echo "$vm: " && virsh domiflist $vm | sed -n "3,$ { s,^,\t,; p }"; done
}

function virt-list-vm() {
	virsh list --all
}


function virt-list-host() {
    while read -r net;do
        virsh net-dhcp-leases $net |tail -n+3 |grep .
    done < <(virsh net-list |tail -n+3 | awk '{print $1}'|grep .)
}

function virt-ssh() {
	local s=$(virsh net-dhcp-leases default  |grep ipv4 |awk '{print($5,$6)}'|fzf)
	echo $s
	local ip=$(echo $s|awk '{print $1}'|cut -d '/' -f 1)
	ssh cong@$ip
}

function virt-start() {
    local vm=$1
    virsh start $vm
}

function virt-destory-vm() {
    local vm=$1
    virsh destory $vim
    virsh undefine $vim
}

function virt-view() {
	local vm=$(virsh list --all | tail -n +3|fzf|awk '{print $2 }')
    echo $vm
    virt-start $vm
    virt-viewer --connect qemu:///system $vm &!
}
