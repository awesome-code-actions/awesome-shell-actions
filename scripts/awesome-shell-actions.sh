#!/bin/zsh

source_it() {
    local p=$1
    if [ -f "$p" ]; then
        if [[ $p == *.sh ]]; then
            echo "source file $p"
            . $p
            if [[ $? -ne 0 ]]; then
             echo "source $p fail"
            fi
        fi
    fi

    if [ -d "$p" ]; then
        echo "source dir $p start"
        for file in $p/*; do
            source_it "$file"
        done
        echo "source dir $p over"
    fi
}

awesome-shell-actions-load() {
    echo "load start"
    awesome_shell_actions_path=$1
    if [ -d $awesome_shell_actions_path ] 
    then 
        echo "find awesome-shell-actions in ${awesome_shell_actions_path} start load"
        source_it $awesome_shell_actions_path/scripts
        if [[ $? -ne 0 ]]; then
            echo "source actions fail"
        fi
        for action in $(print -rl ${(k)functions_source[(R)*awesome*]});do 
            short=$(echo $action | sed 's/-//g')
            alias $short=$action
        done
    else
        echo "cloud not find awesome-shell-actions in $awesome_shell_actions_path ignore"
    fi
    echo "load over"
}

edit-x-actions() {
    cmd=$(list-x-actions|fzf)
    source_file=$(type $cmd|rg -o '.* from (.*)' -r '$1'  |tr -d '\n\r')

    cmd_start_line=$(grep -no "$cmd()" $source_file |cut -d ':' -f 1 |tr -d '\n\r')
    echo $source_file
    echo $cmd_start_line
    vim +$cmd_start_line $source_file
}

which-x-actions() {
    cmd=$(list-x-actions|fzf)
    which $cmd
}

list-x-actions() {
    print -rl ${(k)functions_source[(R)*awesome*]}
}

count-actions() {
    print -rl ${(k)functions_source[(R)*awesome*]} |wc -l
}

random() {
    local size=$1
    echo ${RANDOM:0:$size}
}

node_s() {
    # 读取字符串作为node脚本并执行
    local code=$1
    echo $code ~/
    echo $code
}

rust_s() {

}

python3_s() {

}
