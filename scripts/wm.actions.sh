#!/bin/bash

function wm-wk-and-web() (
  local wk=$(xorg-list-win | grep 'code' | grep -v 'note' | awk '{print $1}')
  local web=$(xorg-list-win | grep 'firefox' | awk '{print $1}')
  xorg-to-left $wk
  xorg-to-right $web
  return
)
