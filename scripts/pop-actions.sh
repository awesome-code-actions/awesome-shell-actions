#!/bin/bash

function pop-start() {
  if [[ "$(pop-ami-focus)" == "true" ]]; then
    pop-on-focus
  else
    pop-on-unfocus
  fi
}

function pop-ami-focus() {
  if [[ "$(xdotool getactivewindow getwindowname)" == "custom" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

function pop-on-focus() {
  notify-send "focus"
  xdotool getactivewindow windowminimize
}

function pop-on-unfocus() {
  notify-send "un focus"
  wmctrl -a custom
  wmctrl -r custom -e 1,4000,500,2000,2000
  pop-run
}

function pop-run() {
  local session=~/.kitty-room/custom
  kitty @ --to unix:$session send-text "\x03"
#   kitty @ --to unix:$session send-text "zsh \x0d"
  kitty @ --to unix:$session send-text "pop-cmds \x0d"
}

function pop-cmds() {
  rm -rf /tmp/pop-app.json || true
  local pop_id=$(xdotool getactivewindow)
  local app=$(gnome-nth-focused-window 1)
  echo "$app" >/tmp/pop-app.json
  local id=$(echo "$app" | jq -r .id)
  local find="false"
  local m=""

  while read -r matcher; do
    if [[ "$(eval $matcher /tmp/pop-app.json)" == "true" ]]; then
      find="true"
      m=$matcher
      break
    fi
  done < <(list-x-actions | grep pop-cmd-match)
  if [[ "$find" == "false" ]]; then
    echo "could not find match ignore $app"
    return
  fi

  local lister="$(echo $m | sed 's/pop-cmd-match//g')pop-cmd-list"
  local cmd=$(eval "$lister" | fzf)
  gnome-focus $id
  eval "$cmd"
  xdotool  windowminimize $pop_id
}
