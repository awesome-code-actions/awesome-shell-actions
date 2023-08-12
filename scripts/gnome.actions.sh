#!/bin/bash


function gnome-cur-version() {
  gnome-shell --version
}

function gnome-shell-eval() {
  local cmd="$@"
  local raw=$(gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval "$cmd")
  echo "$raw"
}

function gnome-shell-eval-json() {
  # TODO buged
  local cmd="$@"
  local raw=$(gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval "$cmd")
  echo "$raw" >/tmp/alt-tab.raw
  rm -rf /tmp/alt-tab.json || true

  python3 - <<-"START"
import os
import json
raw= open("/tmp/alt-tab.raw").read()
# print(raw)
if not raw.startswith("(true,"):
    os.abort()
raw=raw.strip().lstrip("(true,").rstrip(")").strip()
if raw.startswith("'"):
    raw=raw.strip("'")
if raw.startswith('"'):
    raw=raw.strip('"')
raw_text=""
index=0
for b in raw.split("0x"):
    index=index+1
    braw=b.replace("0x","")
    if len(braw)>2:
        continue
    braw_bytes=bytes.fromhex(braw)
    try:
        text=braw_bytes.decode("utf-8")
        raw_text+=text
       #print(braw_bytes,braw,index,text)
    except Exception as inst:
        pass
        # ignore

# print(raw_text)
raw_json=json.loads(raw_text)
open("/tmp/alt-tab.json","w").write(json.dumps(raw_json))
	START
  cat /tmp/alt-tab.json | jq
}

function gnome-list-current-focused-windows() {
  # gnome-shell-eval 'global.display.get_tab_list(Meta.TabList.NORMAL_ALL,global.workspace_manager.get_active_workspace()).map(x => `${x.wm_class}`)'
  gnome-shell-eval-json "$(
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

function gnome-screen() {
   local out=/home/cong/Pictures/shoot.$(date +%s).jpg
    gnome-screenshot -a  -f $out
    while true;do
    if [ -f "$out" ];then
            sleep 1
            QT_QPA_PLATFORM=wayland ksnip -e $out &!
            break
    fi
    sleep 1
    done
}

function gnome-alt-tab() {
  gnome-shell-eval-json "$(
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
        title: `${win.title}`,
        id: `${win.get_id()}`,
        pid: `${win.get_pid()}`,
        class_instance: `${win.get_wm_class_instance()}`,
        gtk_id: `${win.get_gtk_application_id()}`,
        gtk_bus: `${win.get_gtk_unique_bus_name()}`
    })
}
let raw=JSON.stringify(ret)
let hex=""
for (const [i,c] of Array.from(raw).entries()) {
    global.log(i,c,'0x'+c.charCodeAt(0).toString(16))
    hex+='0x'+c.charCodeAt(0).toString(16)
}
hex
EOF
  )"
}

function gnome-focus() {
  local id="$1"
  gnome-shell-eval "$(
    cat <<EOF
const Main = imports.ui.main;
let mode=Meta.TabList.NORMAL_ALL
let workspace=global.workspace_manager.get_active_workspace()
let wins=global.display.get_tab_list(mode,workspace)
let ret=[]
for (const [i,win] of wins.entries()) {
    if (win.get_id()=="$id") {
        global.log("do ",win.title)
        Main.activateWindow(win)
        break
    }
}

EOF
  )"
}

function gnome-focus-sel() {
  local id=$(gnome-alt-tab | jq -r '.[]|"\(.)"' | fzf | jq -r '.id')
  echo $id
  gnome-focus $id
}
