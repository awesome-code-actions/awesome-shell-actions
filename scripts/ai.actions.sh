#!/bin/bash

function ai-notebook-gen() {
    local fpath="$1"
    local filter="$2"
    local normal_fpath=$(echo "$fpath" | sed 's|/|_|g' | sed 's| ||g')
    find "$fpath" -type f -name "*.$filter" -print0 |
        while IFS= read -r -d '' file; do
            echo "===== $file ====="
            cat "$file"
            echo
        done >./$normal_fpath.$filter.txt
}

function ai-test-glm() {
	local key=$1
	return
}