#!/bin/bash

function chrome-kill-me() {
  ps -aux | grep chrome | awk '{print $2}' | xargs -I{} kill -9 {}
}

function chrome-mac-open-debug() (
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222
)
function chrome-get-debug-ws-ep() (
  zmx-log "chrome get ws"
  local ep=$(curl -s http://localhost:9222/json/version | jq -r '.webSocketDebuggerUrl')
  if [ -n "$ep" ]; then
    echo "$ep"
    return
  fi
  pkill chrome
  #   /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
  /opt/google/chrome/chrome --remote-debugging-port=9222 &>~/.chrome.log &
  while true; do
    zmx-log "keep try"
    ep=$(curl -s http://localhost:9222/json/version | jq -r '.webSocketDebuggerUrl')
    if [ -n "$ep" ]; then
      echo "$ep"
      return
    fi
    sleep 1
  done
)
