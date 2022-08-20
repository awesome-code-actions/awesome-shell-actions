#!/usr/bin/env bash
function rg-only-show-file-name() {
    local pattern="$1"
    rg --files-with-matches $pattern
}

function rg-follow-link() {
    local pattern="$1"
    rg --follow $pattern
}

function rg-filter-file() {
    # example
    # -g '*.{c,h}'
    # -'*.yaml'
    local pattern="$1"
    local file_filter="$2"
    rg -g $file_filter $pattern
}
