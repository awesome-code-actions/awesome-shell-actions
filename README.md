# awesome-shell-actions
## what it is
a collection of all actions

## how to load
add below code to you zshrc/bashrc
```bash
load_awesome_shell_actions() {
    awesome_shell_actions_path=$1
    if [ -d $awesome_shell_actions_path ] 
    then 
        echo "find awesome-shell-actions in ${awesome_shell_actions_path} start load"
        for file in $awesome_shell_actions_path/scripts/*.sh; do
            echo "load $file"
            . "$file"
        done
    else
        echo "cloud not find awesome-shell-actions in $awesome_shell_actions_path ignore"
    fi
}

load_awesome_shell_actions $YOU_PATH
```