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
