#!/bin/bash

function gnome-cur-version() {
  gnome-shell --version
}

function gnome-list-workspace() (
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
  local old_name=$(gnome-get-workspace-name-via-id $id)
  log "ws name change $old_name $name"
  on-workspace-name-change $old_name $name
  gsettings set org.gnome.desktop.wm.preferences workspace-names "$ns"
  echo "$ns"
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