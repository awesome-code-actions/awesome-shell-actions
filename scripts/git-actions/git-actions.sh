#!/bin/zsh

function git-pull-current-remote-branch() {
  git pull
}

function git-force-pull() {
  current_branch=$(git branch --show-current | tr -d '\n\r')
  git checkout -b "$current_branch"-bak-$(date '+%Y-%m-%d-%H-%M-%S')
  git checkout master
  git branch -D $current_branch
  git checkout $current_branch
}

# 检查当前的repo的帐号用户信息
function git-check-current-info() {
  echo "current info"
  echo user is "=>"$(git config user.name)"<="
  echo emil is "=>"$(git config user.email)"<="
}

function git-set-origin() {
  # @arg-len: 1
  url=$1
  git remote set-url origin $url
}

function git-set-global-user() {
  name=$1
  git config --global user.name $name
}

function git-set-global-email() {
  email=$1
  git config --global user.email $email
}

# 查看当前commit的tag 如果当前commit没有tag 那么就是空
function git-see-current-tag() {
  git tag --points-at HEAD
}

# 查看包含特定comit的tag
function git-which-tag-contains-this-commit() {
  commit=$1
  git tag --contains $commit
}

# 查看包含特定comit的分支
function git-which-branch-contains-this-commit() {
  commit=$1
  git branch --contains $commit
}

# 查看包含某个特定文件 且文件内含有特定字符串的tag
function git-which-tag-contains-this-file-and-text() {
  file=$1
  text=$2
  ~/.zsh/awesome-shell-actions/scripts/git-actions/git-which-tag-contains-this-text.cr $file $text
}

function git-which-tag-contains-this-text() {
  # 获取当前存储库的分支列表
  # 遍历每个分支
  while read -r branch; do
    echo "$branch"
    git checkout $branch &>/dev/null

    # 搜索字符串
    echo "Searching in branch: $branch"
    local out=$(git grep $1)
    if [[ -z "$out" ]]; then
      echo "Not found"
    else
      echo " -- $out --"
    fi
  done <<<$(git branch --list | grep -v '*')
  #   for branch in $branches; do
  #     # 切换到分支
  #   done

}

function git-commit-no-edit() {
  git commit --amend --no-edit --allow-empty
}

function git-checkout-master() {
  git checkout master
}

function git-contributor-by() {
  user=$1
  git log --author="$user" --pretty=tformat: --numstat | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "added lines: %s removed lines : %s total lines: %s\n",add,subs,loc }'
}

function git-show-commit-by-user() {
  user=$1
  git log --oneline --author="$user"
}

function git-push-origin() {
  # @tag: git-get-current_branch-name
  current_branch=$(git branch --show-current | tr -d '\n\r')
  git push origin $current_branch $@
}

function git-force-push-origin() {
  current_branch=$(git branch --show-current | tr -d '\n\r')
  git push origin $current_branch -f
}

function git-commit-no-edit-and-force-push-origin() {
  git-commit-no-edit
  git-force-push-origin
}

function git-commit-no-edit-and-force-push-origin-no-verify() {
  git-commit-no-edit
  current_branch=$(git branch --show-current | tr -d '\n\r')
  git push origin $current_branch -f --no-verify
}

function git-add-modify-files-commit-update-and-push-origin() {
  git add -u
  git status
  git commit -m "update"
  git status
  git push origin
}

function git-add-modify-files-commit-no-edit-and-force-push-origin() {
  git add -u
  git status
  git-commit-no-edit
  git status
  git-force-push-origin
}

function git-unset-http-proxy() {
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}

function git-reset-all() {
  zd
  git reset --hard HEAD
  git clean -fxd
}

function git-search-all-history() {
  local msg=$1
  git rev-list --all | (
    while read revision; do
      git grep -F "$msg" $revision
    done
  )
}

function git-sync() {
  local p=$1
  local base=$(dirname $(zmx-find-path-of-action))
  echo $base
  echo "--$p--"
  $base/git-sync $p
}


function git-reverse-book-init() {
    git log --pretty-format="%H"  --follow xx > xx.change
}

function git-rever-book-zero() {
    
}
function git-reverse-book-next() {
    local change=$1
    local cur=$(git log --pretty=format:'%H'  |head -n 1)
    local next=$(cat $change|grep $cur -B 1)
    echo "$cur $next"
}