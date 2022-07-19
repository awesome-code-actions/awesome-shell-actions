#!/bin/bash

WS_HOME=$HOME/sm/ws
function ws-open() {
    local ws=$(ls $WS_HOME | fzf)
    code $WS_HOME/$ws
}