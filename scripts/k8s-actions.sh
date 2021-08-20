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
    echo $pod $ns
    kubectl exec -it $pod -n $ns sh
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

}

function k-replace-to-tail() {
    # arg-len: 2
    # 将pod里的container的command替换成tail 并将原始的deployment dump成json 保存下来

    local deployment=$1
    local ns=$1

    local pod="echo-resty-68c79c758f-ttlpv"
    local ns="alb-wc"
    local pod_json=$(kubectl get po -n $ns $pod -o json)
    node_s $pod_json
    local patch_json=$(node_s `
        console.log(`$pod_json`)
    `)
    echo $patch_json
}

func k-config-delete() {
    kubectl config get-contexts -o name|fzf -m |xargs -i{} kubectl config delete-context {}
}

function k-config-use() {
    kubectl config use-context $(kubectl config get-contexts -o name|fzf -m)
}

function k-eval-in-all-pod() {
    #@ arg-len:4
    local ns=$1
    local label=$2
    local container=$3
    local cmd=$4
    echo n $ns l $label c $container c $cmd
    kubectl get po -n $ns -l $label -o wide |tail -n +2 |awk '{print $1}' |xargs -I{} kubectl exec {} -c $container -n $ns -- sh -c  "$cmd"
    
}

alias k-switch=k-config-use
