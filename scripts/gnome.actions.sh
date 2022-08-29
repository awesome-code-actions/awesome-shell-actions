#!/bin/bash

function gnome-cur-version() {
    gnome-shell --version
}

function gnome-shell-eval() {
    local cmd="$@"
    local raw=$(gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval "$cmd")
    # TODO what the fuck....
    local out=$(echo "$raw" | sed "s/(true, //g" | sed "s/)$//g")
    local out=$(echo "$out" | sed 's|\\"|"|g')
    local out=$(echo "$out" | sed "s/\"'//g" | sed "s/'\"//g")
    local out=$(echo "$out" | sed "s/\"\"\[/\[/g")
    local out=$(echo "$out" | sed "s/\]\"\"\[/\]/g")
    echo $out | jq
}

function gnome-decode() {
    read raw
    echo $raw
}

function gnome-list-current-focused-windows() {
    # gnome-shell-eval 'global.display.get_tab_list(Meta.TabList.NORMAL_ALL,global.workspace_manager.get_active_workspace()).map(x => `${x.wm_class}`)'
    gnome-shell-eval "$(
        cat <<\EOF
function log(msg){global.log("wg: "+msg)}
let mode=Meta.TabList.NORMAL_ALL
let workspace=global.workspace_manager.get_active_workspace()
let wins=global.display.get_tab_list(mode,workspace).map(x => `${x.wm_class}`)
let raw=JSON.stringify(wins)
log(raw)
raw
EOF
    )"
}

function gnome-nth-focused-window() {
    gnome-alt-tab | jq ".[]|select(.index==$1)"
}

function gnome-alt-tab() {
    gnome-shell-eval "$(
        cat <<\EOF
let mode=Meta.TabList.NORMAL_ALL
let workspace=global.workspace_manager.get_active_workspace()
let wins=global.display.get_tab_list(mode,workspace)
let ret=[]
for (const [i,win] of wins.entries()) {
    ret.push({
        index: i,
        class: `${win.wm_class}`,
        workspace: `${ win.get_workspace().index() }`,
        title: `${win.title}`
    })
}
let raw=JSON.stringify(ret)
raw
EOF
    )"
}
