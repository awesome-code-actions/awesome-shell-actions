#!/bin/zsh

git-pull-current-remote-branch() {
    git pull
}

# 检查当前的repo的帐号用户信息
git-check-current-info() {
    echo user is "=>"$(git config user.name)"<="
    echo emil is "=>"$(git config user.email)"<="
}

git-set-origin() {
    url=$1
    git remote set-url origin $url
}

git-set-global-user() {
    name=$1
    git config --global user.name $name
}

git-set-global-email() {
    email=$1
    git config --global user.email $email
}


# 查看当前commit的tag 如果当前commit没有tag 那么就是空
git-see-current-tag() {
    git tag --points-at HEAD
}

# 查看包含特定comit的tag
git-which-tag-contains-this-commit() {
    commit=$1
    git tag --contains $commit
}

# 查看包含特定comit的分支
git-which-branch-contains-this-commit() {
    commit=$1
    git branch --contains $commit
}

# 查看包含某个特定文件 且文件内含有特定字符串的tag
git-which-tag-contains-this-text() {
    file=$1
    text=$2
    ~/.zsh/awesome-shell-actions/scripts/git-actions/git-which-tag-contains-this-text.cr $file $text 
}

git-commit-no-edit() {
    git commit --amend --no-edit
}