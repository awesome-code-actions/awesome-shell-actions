#!/bin/bash

tmux-kill-other-panel() {
    tmux kill-pane -a
}

tmux-kill-server() {
    tmux kill-server
}

tmux-split-right-panel() {
    tmux split-window -h
}

tmux-split-down-panel() {
    tmux split-window
}

tmux-set-panel-title() {
    title=$1
    tmux select-pane -T $title
}

tmux-set-window-title() {
    title=$1
    tmux rename-window $title
}

tmux-edit-config-file() {
    vim ~/.tmux.conf
}

tmux-rename-current-session() {
    name=$1
    tmux rename-session $name
}

tmux-rename-current-window() {
    name=$1
    tmux rename-window $name
}

tmux-list-pane() {
    tmux list-panes -s -F "#{session_name}:#{window_name}:#{window_index}:#{pane_title}:#{pane_index}"
}

tmux-list-pane-current-window() {
    tmux list-panes -s -F "#{session_name}:#{window_name}:#{window_index}:#{pane_title}:#{pane_index}"
}

tmux-send-key-to-pane() {
    local title="$1"
    shift
    local pane_index=$(tmux-get-paneid $title)
    echo tmux send-keys -t $pane_index "$@"
    tmux send-keys -t $pane_index $@
}

tmux-get-paneid() {
    local title=$1
    tmux list-panes -t $(tmux-get-current-window-id)  -F "#{pane_title}:#{pane_index}" |grep $title | cut -d ':' -f 2 | tr -d '\n\r'
}

tmux-get-current-window-id() {
    local id=$(tmux list-windows |grep active| cut -d ':' -f 1 |tr -d '\n\r')
    echo $id
}

tmux-attach-dt() {
    tmux attach -dt $(tmux ls |cut -d ':' -f 1|fzf)
}

tmux-kill-this-session() {
    local current_session=$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1 | tr -d '\n\r')
    tmux kill-session -t $current_session
}

tmux-kill-session() {
    local session=$(tmux ls | cut -d ':' -f 1|awk '{print $1}'| fzf)
    tmux kill-session -t $session
}


tmux-jumpto-panel-by-regex() {
    name=$1
    pane=$(tmux-list-panel |grep $name)
    pane_index=${pane##*-}
    target_window_index=$(tmux-list-pane |grep $name |cut -d ':' -f 3)
    current_window_index=$(tmux list-windows|grep '*' |cut -d ':' -f 1)
    # if we are in different window jumpto it first
    if [[ $target_window_index == $current_window_index ]] then
        tmux select-panel -t $pane_index
    else
        tmux select-window -t $target_window_index && tmux select-panel -t $pane_index
    fi
}

edit-tmux-config() {
    vim ~/.tmux.conf
}


tmux-list-all-key() {
    tmux list-keys
}

tmux-zoom-current-panel() {
    tmux resize-pane -Z
}

tmux-create-inside-tmux() {
    local name=$1
    tmux new -s "$name" -d
}
