#!/usr/bin/env bash
function rg-only-show-file-name() {
    local pattern="$1"
    rg --files-with-matches $pattern
}
