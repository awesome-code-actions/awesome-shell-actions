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

