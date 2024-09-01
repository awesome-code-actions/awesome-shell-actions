#!/bin/env python3
from invoke import task
import libvirt
import sys

STATE_MAP={
    libvirt.VIR_DOMAIN_NOSTATE: "no_state",
    libvirt.VIR_DOMAIN_RUNNING: "running",
    libvirt.VIR_DOMAIN_BLOCKED: "blocked_on_resource",
    libvirt.VIR_DOMAIN_PAUSED: "paused",
    libvirt.VIR_DOMAIN_SHUTDOWN: "being_shut_down",
    libvirt.VIR_DOMAIN_SHUTOFF: "shut_off",
    libvirt.VIR_DOMAIN_CRASHED: "crashed",
    libvirt.VIR_DOMAIN_PMSUSPENDED: "suspended_by_power_management"
}

def find_mac_of_vm(vm: libvirt.virDomain)->str:
    ifaces = vm.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_LEASE)
    if ifaces:
        for (name, val) in ifaces.items():
            if val['addrs']:
                for addr in val['addrs']:
                    if addr['type'] == libvirt.VIR_IP_ADDR_TYPE_IPV4:
                        mac = val['hwaddr']
                        return mac
    else:
        raise Exception("Unable to retrieve MAC address")
    pass



@task()
def list_vm(_ctx):
    domains=["qemu+ssh://kuku.cong/system","qemu+ssh://k2.cong/system"]
    for d in domains:
        conn = libvirt.open(d)
        for c in conn.listAllDomains():
            vm = conn.lookupByName(c.name())
            name = vm.name()
            [state_int,_] = vm.state()
            state = STATE_MAP[state_int]
            if state_int!=libvirt.VIR_DOMAIN_RUNNING:
                print(" ".join([d,name,state]))
                continue
            network = conn.networkLookupByName("default")
            bridge_name = network.bridgeName()
            mac = find_mac_of_vm(vm)
            dhcp ={x["mac"]:x for x in network.DHCPLeases()}
            ip=dhcp[mac]["ipaddr"]
            host=dhcp[mac]["hostname"]
            print(" ".join([str(x) for x in [d,name,state,mac,ip,host,bridge_name]]))

@task()
def stop_vm(_ctx):
    print("ok")