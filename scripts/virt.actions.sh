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

function virt-init-ssh() {
    if [ ! -z "$1" ]; then
        local ip=$(virt-list-host |grep $1| awk '{print $5}')
        sshpass -p vagrant ssh-copy-id vagrant@$ip
        sshpass -p vagrant ssh-copy-id root@$ip
        return
    fi
	local s=$(virt-list-host |awk '{print($5,$6)}'|fzf)
	local ip=$(echo $s|awk '{print $1}'|cut -d '/' -f 1)
    sshpass -p vagrant ssh-copy-id vagrant@$ip
    sshpass -p vagrant ssh-copy-id root@$ip
}

function virt-get-ip() {
    local name=$1
    local ip=$(virt-list-host |grep $name| awk '{print $5}'| cut -d '/' -f 1)
    echo $ip
}

function virt-ssh() {
    if [ ! -z "$1" ]; then
        local ip=$(virt-get-ip $1)
        ssh vagrant@$ip
        return
    fi
	local s=$(virt-list-host |awk '{print($5,$6)}'|fzf)
	echo $s
	local ip=$(echo $s|awk '{print $1}'|cut -d '/' -f 1)
	ssh vagrant@$ip
}

function virt-root-ssh() {
    if [ ! -z "$1" ]; then
        local ip=$(virt-get-ip $1)
        ssh root@$ip
        return
    fi
	local s=$(virt-list-host |awk '{print($5,$6)}'|fzf)
	echo $s
	local ip=$(echo $s|awk '{print $1}'|cut -d '/' -f 1)
	ssh root@$ip
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

function virt-snap() (
    local vm_filer=$1
    local name=$2
    local vms=$(virt-list-vm |grep $vm_filer| awk '{print $2}')
    while read -r vm;do
        echo "snap $vm $name"
        virsh snapshot-create-as --domain $vm --name "$name"
    done < <(echo $vms)
)

function virt-expand-vm-disk() (
    local vm=$1
    local size=$2
    if [ -z "$vm" ]; then
        vm=$(virsh list --all | tail -n +3|fzf|awk '{print $2 }')
    fi
    local image=$(virsh domblklist $vm |grep vda |awk '{print $2}') 
    echo $vm $image
    sudo qemu-img info $image
    sudo qemu-img resize $image $size
    # 进入到虚拟机中，重新扩展分区
    # local m=$(df -hT | grep mapper)
    # sudo lvextend -r -l +100%FREE /dev/mapper/system-root

    return
)

function virt-view() {
	local vm=$(virsh list --all | tail -n +3|fzf|awk '{print $2 }')
    echo $vm
    virt-start $vm
    virt-viewer --connect qemu:///system $vm &!
}
