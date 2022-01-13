shell-reload-zsh() {
    source ~/.zshrc
    if [ -f "~/.zshrc.zwc" ]; then
        echo "zwc exists"
        rm ~/.zshrc.zwc
    fi
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

default-proxy() {
    set-proxy http://127.0.0.1:20172
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
    default-proxy
}

edit-zsh-config() {
    vim ~/.zshrc
}

grant-run-permissions() {
    exe_path=$1
    chmod a+x $exe_path
}


atuin_fzf() {
    cmd=$(atuin h l --cmd-only | fzf )
    echo "eval " $cmd
    eval $cmd
}

copy-current-abs-to-clipboard() {
    echo $PWD  | xclip -selection c
}

copy-current-name-to-clipboard() {
    echo $(basename "$PWD") | xclip -selection c
}

while-true() {
    # @arg-len: 1
    cmd=$1
    while true; do eval $cmd ;sleep 1;echo "-----\n";done
}

copy-last-command() {
    fc -ln -1 |tr -d '\n\r' | xclip -selection c
}

rerun-last-command() {
    eval $(fc -ln -1 |tr -d '\n\r')
}

type-it() {
    xdotool sleep 4 type "$1"
}

type-clipboard() {
    text=$(xclip -selection c -o)
    echo "wait 3s and type -- $text --"
    xdotool sleep 3 type "$text"
}

show-current-window() {
    #category: glasses gnome gnome-shell
    dbus-send --session --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.display.get_tab_list(Meta.TabList.NORMAL_ALL, global.workspace_manager.get_active_workspace()).map(x => x.wm_class)'  | grep -Po "\[.*\]"
}

swap() {
    # @arg-len:2
    local left=$1
    local right=$2
    cp $left $left.swap.temp
    mv $right $left
    mv $left.swap.temp $right
}

ssh-list-all-host() {
    rg -L '^Host\s*.*$' /etc/ssh 2>/dev/null |grep -v '\*' |grep -v 'error'
}

ssh2() {
    ssh $(rg -L '^Host\s*.*$' /etc/ssh 2>/dev/null |grep -v '\*' |grep -v 'error'|awk '{print $2}' |fzf)
}