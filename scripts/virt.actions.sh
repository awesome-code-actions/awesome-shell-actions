#!/bin/bash

function virt-view() {
	local vm=$(virsh list --all | tail -n +3|fzf|awk '{print $2 }')
    echo $vm
    virt-start $vm
    virt-viewer --connect qemu:///system $vm &!
}

function virt-connect-local-win10() {
 virt-viewer --connect qemu:///system win10 &!
}

function virt-connect-local-win10() {
 virt-viewer --connect qemu:///system win10 &!
}