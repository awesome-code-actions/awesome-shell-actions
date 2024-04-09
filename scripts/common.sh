#!/usr/bin/env bash

function time_now() {
    echo $(date +%s%3N)
}

function time_format_time_diff() {
    local start=$1
    local end=$2
    echo $(echo "scale=3; ($end-$start)/1000" | bc)s
}

function log() {
    
}