#!/bin/bash

function tmux-kill-server() {
  tmux kill-server
}

function tmux-cur-pane-t() {
  tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}'
}

function tmux-list-pane-t() {
  tmux list-panes -s -F "#{session_name}:#{window_index}.#{pane_index} #{@mytitle}"
}

function tmux-set-panel-title() {
  tmux-set-panel-title-pane "$(tmux-cur-pane-t)" "$1"
}


function tmux-set-panel-title-pane() {
  local t=$1
  local title=$2
  tmux set -p -t "$t" @mytitle "$title"
}

function tmux-save() (
  python $SHELL_ACTIONS_BASE/scripts/tmux.py tmux-save
)

function tmux-load() (
  tmux display-popup "zsh -c \"source ~/.zshrc; cd $PWD;pwd;python $SHELL_ACTIONS_BASE/scripts/tmux.py tmux-load $1\"" &
)

function tmux-kill-other() (
  tmux kill-window -a && tmux kill-pane -a
)

function tmux-boot-cur() {
  tmux-boot-pane $(tmux-cur-pane-t) "$1"
}

function tmux-set-panel() {
  local t=$1
  local title=$2
  local booter=$3
  tmux set -p -t "$t" @mytitle "$title"
  tmux-boot-pane "$t" "$booter"
}

function tmux-boot-pane() {
  local t=$1
  local booter="$2"
  tmux set -p -t "$t" @mybooter "$booter"
  local cmd=$(
    cd $SHELL_ACTIONS_BASE/scripts
    python3 tmux.py gen_tmux_send_keys "$booter"
  )
  if [[ -z $t ]]; then
    cmd="tmux send-keys $cmd"
  else
    cmd="tmux send-keys -t $t $cmd"
  fi
  echo "$cmd"
  eval "$cmd"
}

function tmux-set-window-title() {
  title=$1
  tmux rename-window $title
}

function tmux-rename-current-session() {
  name=$1
  tmux rename-session $name
}

function tmux-rename-current-window() {
  name=$1
  tmux rename-window $name
}

function tmux-list-pane() {
  tmux list-panes -s -F "#{session_name}:#{window_name}:#{window_index}:#{pane_title}:#{pane_index}"
}

function tmux-list-pane-current-window() {
  tmux list-panes -s -F "#{session_name}:#{window_name}:#{window_index}:#{pane_title}:#{pane_index}"
}

function tmux-send-key-to-pane() {
  local title="$1"
  shift
  local pane_index=$(tmux-get-paneid $title)
  echo tmux send-keys -t $pane_index "$@"
  tmux send-keys -t $pane_index "$@"
}

function tmux-get-paneid() {
  local title=$1
  tmux-list-current-window-panel | grep $title | cut -d '~' -f 2 | tr -d '\n\r'
}

function tmux-list-current-window-panel() {
  tmux list-panes -t $(tmux-get-current-window-id) -F "#{pane_title}#{pane_index}" | grep '~'
}

function tmux-get-current-window-id() {
  local id=$(tmux list-windows | grep active | cut -d ':' -f 1 | tr -d '\n\r')
  echo $id
}

function tmux-attach-dt() {
  tmux attach -dt $(tmux ls | cut -d ':' -f 1 | fzf)
}

function tmux-kill-this-session() {
  local current_session=$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1 | tr -d '\n\r')
  tmux kill-session -t $current_session
}

function tmux-kill-session() {
  local session=$(tmux ls | cut -d ':' -f 1 | awk '{print $1}' | fzf)
  tmux kill-session -t $session
}

function tmux-jumpto-panel-by-regex() {
  name=$1
  pane=$(tmux-list-panel | grep $name)
  pane_index=${pane##*-}
  target_window_index=$(tmux-list-pane | grep $name | cut -d ':' -f 3)
  current_window_index=$(tmux list-windows | grep '*' | cut -d ':' -f 1)
  # if we are in different window jumpto it first
  if [[ $target_window_index == $current_window_index ]]; then
    tmux select-panel -t $pane_index
  else
    tmux select-window -t $target_window_index && tmux select-panel -t $pane_index
  fi
}

function tmux-edit-config() {
  vim ~/.tmux.conf
}

function tmux-list-all-key() {
  tmux list-keys
}

function tmux-zoom-current-panel() {
  tmux resize-pane -Z
}

function tmux-create-inside-tmux() {
  local name=$1
  tmux new -s "$name" -d
  tmux switch -t $name
}

function tmuxc-kill-other-panel() {
  tmux kill-pane -a
}

function tmuxc-split-right-panel() {
  tmux split-window -h
}

function tmuxc-split-down-panel() {
  tmux split-window
}

function tmuxc-edit-config-file() {
  vim ~/.tmux.conf
}

function tmuxc-select-sessions() {
  local n=$(tmux ls | awk '{print $1}' | tr -d ':' | fzf)
  tmux switch-client -t $n
}

function tmux-set-cwd() {
  local mycwd="$@"
  tmux set -p @mycwd "$mycwd"
}
