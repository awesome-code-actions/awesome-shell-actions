#!/bin/bash

function xorg-current-workspace-id() (
  wmctrl -d | grep '*' | cut -d ' ' -f1
)

function xorg-get-winid-via-class() (
  wmctrl -l -x | grep $1 | awk '{print $1}'
)

function xorg-list-win-all() (
  wmctrl -l -x
)

function xorg-list-win() (
  local cur_ws=$(xorg-current-workspace-id)
  wmctrl -l -x | grep " $cur_ws "
)

function xorg-current-active-winid() (
  wmctrl -l -x
)

function xorg-current-active() (
  local out=$(xdotool getactivewindow getwindowname)
  zmx-log $out
  echo $out
)

function xorg-min-all() (
  wmctrl -k on
)

function xorg-select-winid() (
  xorg-list-win | fzf | awk '{print $1}'
)

function xorg-min() (
  local win=${1-$(xorg-select-winid)}
  xdotool windowminimize $win
)

function xorg-max() (
  local win=${1-$(xorg-select-winid)}
  wmctrl -i -r $win -b remove,maximized_vert,maximized_horz
  xdotool getactivewindow windowsize 100% 100%
  xdotool getwindowfocus windowmove 0 0
  return
)

export WM_XX=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
export WM_YY=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

function wm-resolve() (
  local name=$1
  if [[ "$name" == "right" ]]; then
    echo "0,$(expr $WM_XX / 2),0,$(expr $WM_XX / 2),$WM_YY"
  fi
  if [[ "$name" == "left" ]]; then
    echo "0,0,0,$(expr $WM_XX / 2),$WM_YY"
  fi
)

function xorg-to-right() (
  local win=${1-$(xorg-select-winid)}
  wmctrl -i -r $win -b remove,maximized_vert,maximized_horz
  wmctrl -i -a $win
  wmctrl -ir $win -e "$(wm-resolve 'right')"
)

function xorg-to-left() (
  local win=${1-$(xorg-select-winid)}
  wmctrl -ir $win -b remove,maximized_vert,maximized_horz
  wmctrl -ia $win
  wmctrl -ir $win -e $(wm-resolve "left")
)

function xorg-list-win-with-name() (
  while read -r line; do
    local ns=$(echo "$line" | awk '{print $2}')
    local name=$(gnome-get-workspace-name-via-id $ns)
    echo "$name $line"
  done < <(wmctrl -l)
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
