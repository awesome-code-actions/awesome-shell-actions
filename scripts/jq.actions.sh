#!/bin/bash

function jq-static-install() {
  docker cp $(docker run -d wesleydeanflexion/busybox-jq):/bin/jq ./
}

function jq-install-centos() {
  yum install epel-release -y
}
