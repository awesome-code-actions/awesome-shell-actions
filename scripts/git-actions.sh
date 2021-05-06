#!/bin/bash
git-pull-current-remote-branch() {
    git pull
}

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

git-see-current-tag() {
    git tag --points-at HEAD
}

git-commit-no-edit() {
    git commit --amend --no-edit
}