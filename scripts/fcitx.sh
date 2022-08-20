#!/usr/bin/env bash
function fcitx-status() {
    # version
    fcitx -v
    # is running
    echo "status:" fcitx-run-status
    # current input method
}

function fcitx-reload-config() {
    fcitx-remote -r
}

function fcitx-run-status() {
    if [[ $(fcitx-remote) == "0" ]]; then
        echo "close"
    elif [[ $(fcitx-remote) == "1" ]]; then
        echo "inactive"
    elif [[ $(fcitx-remote) == "1" ]]; then
        echo "active"
    fi
}
