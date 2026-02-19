#!/usr/bin/env bash
function wall-ami-been-fucked() {
    wall_status=""
    wall_status=$(
        curl -m 3 -L --socks5 127.0.0.1:20170 -s -o /dev/null -w "%{time_total}  code:%{http_code}" 'https://www.google.com/search?channel=fs&client=ubuntu&q=apple' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed
    )
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "yes,you are been fuck"
    else
        echo "noop,delay " $(echo $wall_status | awk "{print \$1}") "s"
    fi
}

function wall-status() {
    curl -m 3  -s -o /dev/null -w "wall: %{time_total} %{http_code}" 'https://www.google.com/search?channel=fs&client=ubuntu&q=apple' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed
}