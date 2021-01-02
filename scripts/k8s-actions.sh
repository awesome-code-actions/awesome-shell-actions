function k8s-k8s-list-all-k8s() {
    kubectl config get-contexts
}


function k8s-pod-get-all-namespaces {
    kubectl get po --all-namespaces=true
}