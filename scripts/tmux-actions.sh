#!/bin/bash

function tmux-kill-server() {
    tmux kill-server
}

function tmux-set-panel-title() {
    title=$1
    tmux select-pane -T $title
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
    tmux list-panes -t $(tmux-get-current-window-id)  -F "#{pane_title}:#{pane_index}" |grep $title | cut -d ':' -f 2 | tr -d '\n\r'
}

function tmux-get-current-window-id() {
    local id=$(tmux list-windows |grep active| cut -d ':' -f 1 |tr -d '\n\r')
    echo $id
}

function tmux-attach-dt() {
    tmux attach -dt $(tmux ls |cut -d ':' -f 1|fzf)
}

function tmux-kill-this-session() {
    local current_session=$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1 | tr -d '\n\r')
    tmux kill-session -t $current_session
}

function tmux-kill-session() {
    local session=$(tmux ls | cut -d ':' -f 1|awk '{print $1}'| fzf)
    tmux kill-session -t $session
}


function tmux-jumpto-panel-by-regex() {
    name=$1
    pane=$(tmux-list-panel |grep $name)
    pane_index=${pane##*-}
    target_window_index=$(tmux-list-pane |grep $name |cut -d ':' -f 3)
    current_window_index=$(tmux list-windows|grep '*' |cut -d ':' -f 1)
    # if we are in different window jumpto it first
    if [[ $target_window_index == $current_window_index ]] ; then
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
