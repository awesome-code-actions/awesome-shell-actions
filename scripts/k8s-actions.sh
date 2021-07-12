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

## arg: None
## description: 获取当前k8s版本
## category: glasses
function k-version() {

}