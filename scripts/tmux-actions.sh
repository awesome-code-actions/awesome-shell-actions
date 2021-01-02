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