shell-reload-zsh() {
    source ~/.zshrc
}

check-proxy() {
    env |grep -i proxy
}

set-proxy() {
    URL=$1
    export HTTPS_PROXY=$URL
    export HTTP_PROXY=$URL
    export https_proxy=$URL
    export http_proxy=$URL
}

unset-all-proxy() {
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset http_proxy
    unset https_proxy
    unset ALL_PROXY
    unset all_proxy
}

reset-all-proxy() {
    source ~/.zshrc
}

edit-zsh-config() {
    vim ~/.zshrc
}

grant-run-permissions() {
    exe_path=$1
    chmod a+x $exe_path
}