#!/bin/bash
git-pull-current-remote-branch() {
    git pull
}

git-check-current-info() {
    echo user is "=>"$(git config user.name)"<="
    echo emil is "=>"$(git config user.email)"<="
}

git-set-global-user() {
    name=$1
    git config --global user.name $name
}

git-set-global-email() {
    email=$1
    git config --global user.email $email
}