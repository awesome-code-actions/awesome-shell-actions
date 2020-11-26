# awesome-shell-actions
## claim
就我自己的观察来看,日常的程序员的工作由一系列action组成,这种action的组合可以类比于所有在emacs上的操作由一系列command组成.
unix哲学所带来的强大的复用和组合的能力所导致的一个后果是,为了表达出这些有明确语义的action我们往往要组合多个命令行工具(awk,sed,grep etc).在这时关注的重点不由得从具体的语义(想做什么)变成了繁琐的实现(该怎么做).
正如emacs的精华(在我看来)在于强大的自定义command的能力,和良好的交流这些command的场所(包管理市场),我们也应当将那些常用的对象和action整理出来,使的对于这些actions的讨论能够有一个场所.从而能够帮助我们找到action的最佳实现,和发现那些之前没有意识到的actions. 

本项目(包括整个awesome-code-actions)旨在整理出那些常用对象的action,给他们一个名字,给程序常与之交互的对象一个抽象一些的方法,使的我们的焦点更关注于对象的语义(对象可以那些方法,我可以对其做什么)而不是语法(具体怎么组合使用工具去达到我们的目的).
awesome-shell-actions 关注于对于组合和调用命令行所能表达的action的整理与维护
每个对象由scripts下的××-actions.sh 定义,脚本中的每个以xx-开始的函数定义了一个以这个对象为主体的action.
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