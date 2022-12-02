#!/bin/bash

function vbox-crate-vm() {
  local name=$1
  local iso=$2
  qemu-img create -f qcow2 -o preallocation=off $name.qcow2 50G
  virt-install --name $name --memory 8096 --vcpus 4 --disk ./$name.qcow2 --cdrom $iso
  # 手动操作直到能ssh为止,然后执行vbox-init-xx OUTVM
  # 然后执行
}

function vbox-create-box() {
  set -x
  local name=$(echo $1 | sed 's/.qcow2//g' | sed 's#./##g')
  echo $name
  if [[ ! -f ./create_box.sh ]]; then
    wget https://raw.githubusercontent.com/vagrant-libvirt/vagrant-libvirt/master/tools/create_box.sh
    chmod a+x ./create_box.sh
  fi
  sudo ./create_box.sh ./$name.qcow2
  vagrant box add $name.box --force --name $name
  local demo=$(
    cat <<EOF
Vagrant.configure("2") do |config|
  name = "shell-$name"
    config.vm.define name do |node|
      node.vm.box = "$name"
      node.vm.hostname = "#{name}"
      node.nfs.verify_installed = false
      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.provider :libvirt do |domain|
          domain.default_prefix = name
          domain.memory = 8096
          domain.cpus = 4
    end
   end
end
EOF
  )
  echo "$demo" >./Vagrantfile
}
function vbox-init-centos7() {
  local mode=$1
  local ip=$2
  if [[ "$mode" == "OUTVM" ]]; then
    echo "outvm"
    wget https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant
    wget https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
    sshpass -p vagrant ssh-copy-id -i vagrant.pub vagrant@$ip
    sshpass -p vagrant ssh-copy-id -i vagrant.pub root@$ip
    sshpass -p vagrant ssh root@$ip "echo vagrant ALL=NOPASSWD:ALL >/etc/sudoers.d/vagrant"
    sshpass -p vagrant ssh vagrant@$ip <<EOF
    $(typeset -f vbox-init-centos7);
    vbox-init-centos7 INVM
EOF
    return
  fi
  if [[ "$mode" != "INVM" ]]; then
    echo "invalid"
    return
  fi
  ip addr
  sudo yum update -y
  whoami
  sudo yum install vim tmux -y
  sudo cat /etc/sudoers.d/vagrant
  sudo rm /etc/machine-id
  sudo touch /etc/machine-id
  echo "send dhcp-client-identifier = hardware;" | sudo tee /etc/dhcp/dhclient.conf
  echo "check"
  sudo cat /etc/dhcp/dhclient.conf
  sudo poweroff
}
