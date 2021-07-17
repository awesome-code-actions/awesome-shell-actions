#!/bin/zsh

awesome-shell-actions-load() {
    awesome_shell_actions_path=$1
    if [ -d $awesome_shell_actions_path ] 
    then 
        echo "find awesome-shell-actions in ${awesome_shell_actions_path} start load"
        for file in $awesome_shell_actions_path/scripts/**/*.sh; do
            echo "load $file"
            . "$file"
        done
    else
        echo "cloud not find awesome-shell-actions in $awesome_shell_actions_path ignore"
    fi
}

edit-x-actions() {
    cmd=$(list-x-actions|fzf)
    source_file=$(type $cmd|rg -o '.* from (.*)' -r '$1'  |tr -d '\n\r')

    cmd_start_line=$(grep -no "$cmd()" $source_file |cut -d ':' -f 1 |tr -d '\n\r')
    echo $source_file
    echo $cmd_start_line
    vim +$cmd_start_line $source_file
}

list-x-actions() {
    print -rl ${(k)functions_source[(R)*awesome*]}
}
