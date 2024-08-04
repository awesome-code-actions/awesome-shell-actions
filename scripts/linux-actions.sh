#!/bin/bash

function openfile-get-limit() {
  echo "current"
  ulimit -n
  echo "all"
  ulimit -aH
  ulimit -nH
  ulimit -nS
}

function openfile-set-limit() {
  local lm=$1
  ulimit -n $lm
}

function edit-which() {
  local w=$1
  vim $(which $w)
}

function ps-mem-human {
  # while true;do sleep 1s ;(date;ps aux |grep alb | /root/cong/numfmt  --from-unit=1024 --to=iec --field 5,6   --padding 6) | tee -a ./mem.log;done
  ps aux | numfmt --from-unit=1024 --to=iec --field 5,6 --padding 6
}

function has-config() {
  grep $1 /boot/config-$(uname -r)
}

function fuck-dns() {
  sudo rm -rf /etc/resolve.conf
  cat /etc/resolve.conf
  local cfg=$(
    cat <<EOF
nameserver 127.0.0.1
EOF
  )
  echo "$cfg" >/etc/resolve.conf
  sudo chattr -i /etc/resolve.conf
}
