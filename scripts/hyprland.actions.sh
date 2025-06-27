#!bin/bash

function hypr-toggle-max() (
  hyprctl dispatch fullscreen 1
)

function hypr-rename-workspace() (
  zmx-log "hypr-rename-workspace called"
  local id="$1"
  if [[ "$id" == "{id}" ]]; then
    id=""
  fi

  if [ -z "$id" ]; then
    id=$(hyprctl activeworkspace -j | jq -r '.id')
  fi
  local new_name=$(rofi -dmenu -i -p "Rename Current Workspace" | xargs)
  if [ -z "$new_name" ]; then
    return
  fi
  zmx-log "Renaming workspace $id to $new_name"
  hyprctl dispatch renameworkspace "$id $new_name"
)

function hypr-reload-waybar() (
  ~/.config/waybar/launch.sh
)

function hypr-switch-window() (
    local curlent_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
  local current_raw=$(hyprctl activewindow -j | jq -r '"\(.pid) @@ \(.address) @@  \(.class)"')
  zmx-log "raw $current_raw"
  local address=$(echo "$current_raw" | awk -F'@@' '{ print $2 }')
  local class=$(echo "$current_raw" | awk -F'@@' '{ print $3 }')
  zmx-log "current address $address class $class"
  local selectd_raw=$(hyprctl -j clients | jq -r '.[] | "wid:\(.workspace.id) x @@ \(.class) @@\(.title) @@ \(.address)"'|grep "wid:$curlent_workspace x" | rofi -dmenu -i -p "Switch Window in Current Workspace" -theme-str 'listview { lines: 10; columns: 2; }')
  local selectd_address=$(echo "$selectd_raw" | awk -F'@@' '{ print $4 }' | xargs)
  zmx-log "selectd address $selectd_address"
  if [ -n "$selectd_address" ]; then
    zmx-log "dispatch address |$selectd_address|"
    hyprctl dispatch focuswindow "address:$selectd_address"
  fi
)
