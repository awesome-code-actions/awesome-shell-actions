#!/bin/bash
function gdb-run {
    local pid=$1
    local cmd=$2
    local gdbinit=$(
        cat <<EOF
        $cmd
        quit
EOF
    )
    echo "$gdbinit" >./gdbinit
    sudo gdb -p $pid -iex "add-auto-load-safe-path $PWD/.gdbinit" -batch
    return
}