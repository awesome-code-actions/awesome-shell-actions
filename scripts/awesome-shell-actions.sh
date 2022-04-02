#!/bin/zsh

function random {
    local size=$1
    echo ${RANDOM:0:$size}
}
