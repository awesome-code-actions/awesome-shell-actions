#!/bin/bash

function kubelet-alone-init() {
  # https://seankhliao.com/blog/12021-09-06-kubelet-containerd-standalone/
  # 1. 安装kubelet containerd cniplugin nerdctl
  yay -S kubelet
  cat <<EOF >/etc/containerd/config.toml

# importart or else it defaults to v1
version = 2

[plugins."io.containerd.grpc.v1.cri".cni]

    # archlinux default
    bin_dir = "/usr/lib/cni"

    # how to configure pod networking
    conf_template = "/etc/cni/cni.template"
EOF
  cat <<EOF >/etc/cni/cni.template
{
  "name": "containerd",
  "cniVersion": "0.4.0",
  "plugins": [{
    "type": "ptp",
    "ipMasq": true,
    "ipam": {
      "type": "host-local",
      "subnet": "{{.PodCIDR}}",
      "routes": [
        {"dst": "0.0.0.0/0"}
      ]
    }
  },{
    "type": "portmap",
    "capabilities": {
      "portMappings": true
    }
  }]
}
EOF
  cat <<EOF >/etc/kubernetes/kubelet.env
KUBELET_ARGS=--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --config /etc/kubernetes/kubelet.yaml
EOF
  cat <<EOF >/etc/kubernetes/kubelet.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  webhook:
    enabled: false
authorization:
  mode: AlwaysAllow
enableServer: false
logging:
  format: text
  sanitization: false
podCIDR: 10.241.1.0/24
staticPodPath: /etc/kubernetes/manifests
EOF
  cat <<EOF >/etc/kubernetes/manifests/httpbin.yaml
apiVersion: v1
kind: Pod
metadata:
  name: httpbin
spec:
  containers:
    - name: httpbin
      image: kennethreitz/httpbin
      ports:
        - name: http
          containerPort: 80
          hostPort: 45678
EOF
  sudo nerdctl -n k8s.io ps
}
