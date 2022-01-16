function k-list-all-k8s() {
    kubectl config get-contexts
}

function k-pod-get-all-namespaces {
    kubectl get po --all-namespaces=true
}

function k-get-image-by-pod-label() {
    label=$1
    kubectl get po --all-namespaces -l $label -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}'
}

function k-get-crd-by-name() {
    label=$1
    kubectl get po --all-namespaces -l $label -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}'
}

function k-list-contexts() {
    kubectl config get-contexts
}

function k-set-replicas() {
    # pod_name=$1
    # pods=$(kubectl get po -A |grep "${pod_name}")
    # echo $pods
    # if [$(echo "$pods"|wc -l) -ne "0"] 
    # then
    #     echo "not one"
    # fi
    # # kubectl config get-contexts
}

function k-list-all-group-and-version() {
    kubectl api-resources
}

function k-list-resource-by-kind() {
    kind = $1
    kubectl api-resources | grep $kind
}

function k-list-kind-by-resource() {
    res = $1
    kubectl api-resources | grep $res
}

function k-set-image() {
    ns=$1
    deployment=$2
    newImage=$3
    echo "set $ns $deployment image to $newimage"
}

function k-use-16() {
    kubectl config use-context kind-k-1.16.5 
}

function see-net-connection() {
    local ns=$1
    local label=$1
    local container=$1

    while true; do kubectl get po -n $ns -l $label -o wide |tail -n +2 |awk '{print $1}' |xargs -I{} sh -c "kubectl exec {} -c $container " -n $ns -- sh -c ' echo -n \$(env|grep HOSTNAME) && echo -n \" \" && cat /proc/net/tcp |wc -l ';sleep l;echo -ne "\n\r";done
}

function k-exec() {
    pod=$(kubectl get po -A |tail -n +2 |fzf --prompt='select a pod >:'|awk '{print $2}')
    ns=$( kubectl get po -A |grep $pod |awk '{print $1}' |tr -d '\n\r')
    c=$(kubectl get pod -n $ns $pod -o jsonpath="{.spec.containers[*].name}" |tr -s '[[:space:]]' '\n'|fzf --prompt='select a container>:')
    echo $pod $ns $c
    kubectl exec -it $pod -n $ns -c $c sh
}

function k-desc() {
    pod=$(kubectl get po -A |tail -n +2 |fzf --prompt='select a pod >:'|awk '{print $2}')
    ns=$( kubectl get po -A |grep $pod |awk '{print $1}' |tr -d '\n\r')
    echo $pod $ns
    kubectl describe po $pod -n $ns 
}

function k-log() {
    pod=$(kubectl get po -A |tail -n +2 |fzf --prompt='select a pod >:'|awk '{print $2}')
    ns=$( kubectl get po -A |grep $pod |awk '{print $1}' |tr -d '\n\r')
    container=$(kubectl get po -n $ns $pod -o json |jq -r ".spec.containers|.[].name"|fzf)
    echo $pod $ns
    kubectl logs -f $pod -c $container -n $ns 
}

function k-edit-deployment(){
    pod=$(kubectl get deployment -A |tail -n +2 |fzf --prompt='select a pod >:'|awk '{print $2}')
    ns=$( kubectl get deployment -A |grep $pod |awk '{print $1}' |tr -d '\n\r')
    echo $pod $ns
    kubectl edit deployment  $pod -n $ns
}

function k-delete() {
    pod=$(kubectl get po -A |tail -n +2 |fzf --prompt='select a pod >:'|awk '{print $2}')
    ns=$( kubectl get po -A |grep $pod |awk '{print $1}' |tr -d '\n\r')
    echo $pod $ns
    kubectl delete po $pod -n $ns 
}

function k-get-all-po() {
    kubectl get po -A
}

function k-get-po-json() {
    pod=$(kubectl get po -A |tail -n +2 |fzf --prompt='select a pod >:'|awk '{print $2}')
    ns=$( kubectl get po -A |grep $pod |awk '{print $1}' |tr -d '\n\r')
    echo $pod $ns
    kubectl get po $pod -n $ns -o json | vim -
}
## arg: None
## description: 获取当前k8s版本
## category: glasses
function k-version() {
    kubectl version
}

function k-replace-to-tail() {
    # @arg-len: 2
    # 将pod里的container的command替换成tail 并将原始的deployment dump成json 保存下来
    local ns=$1
    local deployment=$2
    local container=$3
    if [ "$#" -eq 0 ]; then
        deployment=$(kubectl get deployment -A |tail -n +2 |fzf --prompt='select a deployment >:'|awk '{print $2}')
        ns=$( kubectl get deployment -A |grep $deployment |awk '{print $1}' |tr -d '\n\r')
        container=$(kubectl get deployment -n $ns $deployment -o jsonpath="{.spec.template.spec.containers[*].name}" |tr -s '[[:space:]]' '\n'|fzf --prompt='select a container>:')
    fi
    echo "ns $ns  deployment $deployment container $container"
    # get args
    local liveness=$(kubectl get deployments.apps -n kube-system kube-ovn-controller -o json  | jq ".spec.template.spec.containers[$index].livenessProbe")
    local readiness=$(kubectl get deployments.apps -n kube-system kube-ovn-controller -o json  | jq ".spec.template.spec.containers[$index].readinessProbe")
    local command=$(kubectl get deployments.apps -n kube-system kube-ovn-controller -o json  | jq ".spec.template.spec.containers[$index].command")
    local args=$(kubectl get deployments.apps -n kube-system kube-ovn-controller -o json  | jq ".spec.template.spec.containers[$index].args")
    # index of this container in deployment 
    local index=$(kubectl get deployments.apps -n $ns $deployment -o yaml  | yq  e ".spec.template.spec.containers|to_entries|.[]|select(.value.name=\"$container\").key" -)
    local id=${RANDOM:0:7}
    local deployment_backup_path=./deploymen-$ns-$deployment-backup-$id.yaml
    local patch_path=./deploymentpatch-$ns-$deployment-$container-tail_mode-$id.json-merge-patch.json
    local recover_patch_path=./deploymentpatch-$ns-$deployment-$container-tail_mode-$id.recover.json-merge-patch.json

    kubectl get deployments.apps -n $ns $deployment -o yaml > $deployment_backup_path
    # generate patch
read -r -d "" patch <<EOF
[
  {
    "op": "remove",
    "path": "/spec/template/spec/containers/$index/readinessProbe"
  },
  {
    "op": "remove",
    "path": "/spec/template/spec/containers/$index/livenessProbe"
  },
  {
    "op": "remove",
    "path": "/spec/template/spec/containers/$index/args"
  },
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/$index/command",
    "value": [
      "tail",
      "-f",
      "/dev/null"
    ]
  }
]
EOF
    echo "$patch" >  $patch_path
    if ! jq empty $patch_path 2>/dev/null; then
        echo "invalid json $patch_path"
        jq . $patch_path
        return 1
    fi
    # generate recover patch
read -r -d "" recover_patch <<EOF
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/$index/livenessProbe",
    "value": $liveness
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/$index/readinessProbe",
    "value": $readiness
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/$index/args",
    "value": $args
  },
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/$index/command",
    "value": $command
  }
]
EOF
    echo "$recover_patch" > $recover_patch_path 
    if ! jq empty $recover_patch_path 2>/dev/null; then
        echo "invalid json $recover_patch_path"
        jq . $recover_patch_path
        return 1
    fi


    echo $patch_path
    echo $recover_patch_path
    kubectl patch deployment $deployment -n $ns --type json --patch-file $patch_path 
    echo "recover with: kubectl patch deployment $deployment -n $ns --type json --patch-file  $recover_patch_path"
    # generate run.sh
    local run=$(jq -r --argjson cmd "$command" --argjson args "$args" -n '$cmd+$args' | jq -r '.[]' | tr '\n' ' ')
    echo "run already copy to you clipboard: $run"
    echo $run | xclip -selection c
}

func k-config-delete() {
    kubectl config get-contexts -o name|fzf -m |xargs -i{} kubectl config delete-context {}
}

function k-config-use() {
    kubectl config use-context $(kubectl config get-contexts -o name|fzf -m)
}

function k-eval-in-all-pod() {
    # @arg-len:4
    local ns=$1
    local label=$2
    local container=$3
    local cmd=$4
    echo n $ns l $label c $container c $cmd
    kubectl get po -n $ns -l $label -o wide |tail -n +2 |awk '{print $1}' |xargs -I{} kubectl exec {} -c $container -n $ns -- sh -c  "$cmd"
    
}

alias k-switch=k-config-use


function k-get-cert-info() {
    local ns=$1
    local name=$2
    kubectl get secret -n $ns $name  -o jsonpath="{.data['tls\.crt']}"|base64 -d |openssl x509 -text |grep CN
}

k-get-all-po-containerid(){
    kubectl get pods -A -o jsonpath='{range .items[*]}{@.metadata.name}{" "}{@.metadata.namespace}{"  "}{@.status.containerStatuses[*].containerID}{"\n"}{end}'
}

k-create-ingress() {
    local ingressName=$1
    local backendNs=$2
    local backendSvc=$3
    local port=$4
    local url=$5

ingressYaml=$(cat <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: $ingressName
    namespace: $backendNs
spec:
  rules:
  - http:
      paths:
      - path: $url
        pathType: Prefix
        backend:
          service:
            name: $backendSvc
            port:
              number: $port

EOF
)
echo "$ingressYaml"
echo "$ingressYaml" | kubectl apply -f -
}
