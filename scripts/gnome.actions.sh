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
  echo "it-has-bug.jpg"
  exit
  return
  # TODO buged
  local cmd="$@"
  local raw=$(gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval "$cmd")
  echo "$raw" >/tmp/alt-tab.raw
  if [ -f /tmp/alt-tab.json ]; then
    rm -rf /tmp/alt-tab.json
  fi

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
  #    local out=/home/cong/Pictures/shoot.$(date +%s).jpg
  #     gnome-screenshot -a  -f $out
  #     while true; do
  #     if [ -f "$out" ];then
  #             sleep 1
  #             QT_QPA_PLATFORM=wayland ksnip -e $out &!
  #             break
  #     fi
  #     sleep 1
  #     done
  return
}

function gnome-alt-tab() (
  set -x
  local json=$(
    cat <<"EOF"
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
  )
  gnome-shell-eval-json "$json"
)

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

function gnome-list-workspace() (
  #   local ns=$(gsettings get org.gnome.desktop.wm.preferences workspace-names)
  #   local code=$(
  #     cat <<EOF
  # import re
  # raw="""$ns"""
  # print(" ".join(re.sub(r"""[\[|\]'\,]""",'',raw).split()))
  # EOF
  #   )
  #   local ns=$(python3 -c "$code")
  #   IFS=' ' read -A arr <<<"$ns"
  #   for n in $(wmctrl -l | awk '{print $2}' | sort | uniq); do
  #     local n1=$(($n + 1))
  #     echo "$n ${arr[$n1]}"
  #   done
  #   return
  local ns=$(gsettings get org.gnome.desktop.wm.preferences workspace-names)
  python3 <<EOF
import re
raw="""$ns"""
[print(f"{x[0]} {x[1]}") for x in enumerate(re.sub(r"""[\[|\]'\,]""",'',raw).split())]
EOF
)

function gnome-set-cur-workspace-name() (
  local id=$(gnome-current-workspace-id)
  local name=${1-"$(ui-get-input \"workspace-name:\")"}
  gnome-set-workspace-name $id $name
)
function gnome-set-workspace-name() (
  local id=$1
  local name=$2
  local ns=$(gsettings get org.gnome.desktop.wm.preferences workspace-names)
  local ns=$(
    python <<EOF
import re
raw="""$ns"""
ws={i:n for i,n in enumerate(re.sub(r"""[\[|\]'\,]""",'',raw).split())}
ws[$id]="""$name"""
print(f"""[{','.join([f"'{x}'" for x in ws.values()])}]""")
EOF
  )
  gsettings set org.gnome.desktop.wm.preferences workspace-names "$ns"
  echo "$ns"
)

function gnome-list-win() (
  wmctrl -l -x
)

function gnome-list-win-with-name() (
  while read -r line; do
    local ns=$(echo "$line" | awk '{print $2}')
    local name=$(gnome-get-workspace-name-via-id $ns)
    echo "$name $line"
  done < <(wmctrl -l)
)
function gnome-move-to() (
  local win=$(gnome-list-win | fzf)
  echo "$win"
)

function gnome-current-workspace-id() (
  wmctrl -d | grep '*' | cut -d ' ' -f1
)

function gnome-get-winid-via-class() (
  wmctrl -l -x | grep $1 | awk '{print $1}'
)

function gnome-get-workspace-name-via-id() (
  local id=$1
  local ns=$(gsettings get org.gnome.desktop.wm.preferences workspace-names)
  python <<EOF
import re
raw="""$ns"""
ws=re.sub(r"""[\[|\]'\,]""",'',raw).split()
print(ws[$id])
EOF
)

function rofi-dynamic-workspace-jump-to() (
  while read -r line; do
    local name=$(echo $line | awk '{print $2}')
    echo "workspace-jump-to $name"
  done < <(gnome-list-workspace)
)

function ui-get-input() (
  local prompt=${1-"name: "}
  if [ -n "$2" ]; then
    echo "$2"
    return
  fi

  env | grep IN_ROFI
  if [ -n "$IN_ROFI" ]; then
    echo $(zenity --entry --text="$prompt")
    return
  fi
  a=$(bash -c "read -e -p \"$prompt\" tmp; echo \$tmp")
  echo $a
  return
)

function workspace-jump-to() (
  local name=$1
  echo "jump to $name"
  local id=$(gnome-list-workspace | grep "$name" | awk '{print $1}')
  echo "id $id"
  wmctrl -s $id
)

function gnome-create-workspace() (
  local name=${1-"$(ui-get-input \"workspace-name:\")"}
  echo $name
  local ns=$(gsettings get org.gnome.desktop.wm.preferences workspace-names)
  local ns=$(
    python <<EOF
import re
raw="""$ns"""
ws=re.sub(r"""[\[|\]'\,]""",'',raw).split()
ws.append("""$name""")
print(f"""[{','.join([f"'{x}'" for x in ws])}]""")
EOF
  )
  echo $ns
  gsettings set org.gnome.desktop.wm.preferences workspace-names "$ns"
)
