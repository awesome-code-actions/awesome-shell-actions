#!/bin/bash

tmux-kill-other-panel() {
    tmux kill-pane -a
}

tmux-split-right-panel() {
    tmux split-window -h
}

tmux-split-down-panel() {
    tmux split-window 
}

tmux-set-panel-title() {
    title=$1
    printf '\033]2;%s\033\\' $title
}

tmux-edit-config-file() {
    vim ~/.tmux.conf
}

tmux-move-panel-to-other-window() {
    # prefix break-panel
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
    ## use by tmux-jumpto-panel-by-regex
    ## -s show all window's panel -F show as format
   tmux list-panes -s -F "#{session_name}:#{window_name}:#{window_index}:#{pane_title}:#{pane_index}" 
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