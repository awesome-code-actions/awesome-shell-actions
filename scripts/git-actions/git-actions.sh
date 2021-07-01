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

git-checkout-master() {
    git checkout master
}

git-contributor-a1() {
    user=$1
    git log --author="$user" --pretty=tformat: --numstat |gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "added lines: %s removed lines : %s total lines: %s\n",add,subs,loc }'
}

git-show-commit-by-user() {
    user=$1
    git log --oneline  --author="$user"
}

git-force-push-origin() {
    current_branch=$(git branch --show-current |tr -d '\n\r')
    git push origin $current_branch -f 
}

git-commit-no-edit-and-force-push-origin() {
    git-commit-no-edit
    git-force-push-origin
}
