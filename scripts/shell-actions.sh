#!/usr/bin/env bash
# note zmx depend on zext

function shell-reload-zsh() {
  source ~/.zshrc
  if [ -f "~/.zshrc.zwc" ]; then
    echo "zwc exists"
    rm ~/.zshrc.zwc
  fi
}

function check-proxy() {
  env | grep -i proxy
}

function set-proxy() {
  local URL=$1
  export HTTPS_PROXY=$URL
  export HTTP_PROXY=$URL
  export https_proxy=$URL
  export http_proxy=$URL
  export NO_PROXY=localhost,127.0.0.0,127.0.1.1,127.0.1.1,local.home

}

function default-proxy() {
  set-proxy http://127.0.0.1:20172
}

function default-proxy-kuku() {
  set-proxy http://172.29.230.34:20172
}
function default-proxy-baba() {
  set-proxy http://47.122.17.109:2017
}

function default-proxy-no-rule() {
  set-proxy http://127.0.0.1:20171
}

function unset-all-proxy() {
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset http_proxy
  unset https_proxy
  unset ALL_PROXY
  unset all_proxy
}

function reset-all-proxy() {
  default-proxy
}

function edit-zsh-config() {
  vim ~/.zshrc
}

function grant-run-permissions() {
  exe_path=$1
  chmod a+x $exe_path
}

function atuin_fzf {
  cmd=$(atuin h l --cmd-only | fzf)
  echo "eval " $cmd
  eval $cmd
}

function copy-current-abs-to-clipboard() {
  echo $PWD | xclip -selection c
}

function copy-current-name-to-clipboard() {
  echo $(basename "$PWD") | xclip -selection c
}

function while-true() {
  # @arg-len: 1
  cmd=$1
  while true; do
    eval $cmd
    sleep 1
    echo "-----\n"
  done
}

function copy-last-command() {
  fc -ln -1 | tr -d '\n\r' | xclip -selection c
}

function rerun-last-command() {
  eval $(fc -ln -1 | tr -d '\n\r')
}

function type-it() {
  xdotool sleep 4 type "$1"
}

function type-clipboard() {
  text=$(xclip -selection c -o)
  echo "wait 3s and type -- $text --"
  xdotool sleep 3 type "$text"
}

function show-current-window() {
  #category: glasses gnome gnome-shell
  dbus-send --session --type=method_call --print-reply --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.display.get_tab_list(Meta.TabList.NORMAL_ALL, global.workspace_manager.get_active_workspace()).map(x => x.wm_class)' | grep -Po "\[.*\]"
}

function swap {
  # @arg-len:2
  local left=$1
  local right=$2
  cp $left $left.swap.temp
  mv $right $left
  mv $left.swap.temp $right
}

function ssh-list-all-host() {
  rg -L '^Host\s*.*$' /etc/ssh 2>/dev/null | grep -v '\*' | grep -v 'error'
}

function ssh2 {
  ssh $(rg -L '^Host\s*.*$' /etc/ssh 2>/dev/null | grep -v '\*' | grep -v 'error' | awk '{print $2}' | fzf)
}

function add-history {
  local full_cmd="$@"
  echo "full_cmd $full_cmd"
  local atuin_id=$(atuin history start "$full_cmd")
  atuin history end $atuin_id --exit "0"
}

function turn-screen-off() {
  xset dpms force off
}

function count-code() {
  tokei ./
}

function env-path-list() {
  echo $PATH | sed 's/:/\n/g'
}

function ps-list-child() {
  local pid=$1
  pstree -p $pid -T | tr '-' "\\n" | grep . | sed 's/(\|)/ /g' | grep -v $pid
}
