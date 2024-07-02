#!/bin/bash

function chrome-kill-me() {
  ps -aux | grep chrome | awk '{print $2}' | xargs -I{} kill -9 {}
}

function chrome-get-debug-ws-ep() (
  local ep=$(curl -s http://localhost:9222/json/version | jq -r '.webSocketDebuggerUrl')
  if [ -n "$ep" ]; then
    echo "$ep"
    return
  fi
  /opt/google/chrome/chrome --remote-debugging-port=9222 &>~/.chrome.log &
  sleep 3
  local ep=$(curl -s http://localhost:9222/json/version | jq -r '.webSocketDebuggerUrl')
  echo "$ep"
)
