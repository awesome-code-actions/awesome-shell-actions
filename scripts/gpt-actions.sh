#!/bin/bash
function gpt-install() {
  python3 -m pip install shell-gpt
  return
}

function g() (
  default-gpt-proxy
  sgpt "$@"
  return
)
