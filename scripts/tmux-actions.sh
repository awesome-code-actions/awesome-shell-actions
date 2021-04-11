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