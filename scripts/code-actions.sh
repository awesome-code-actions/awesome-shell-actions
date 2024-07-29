#!/usr/bin/env bash

function code-list-installed-package() {
  code --list-extensions
}

function code-install-package() {
  package=$1
  code --install-extension $package
}

function code-init-wayland() {
  local cfg=$(
    cat <<EOF
--enable-features=WaylandWindowDecorations
--ozone-platform-hint=auto
EOF
  )
  echo "$cfg" >~/.config/code-flags.conf
}
