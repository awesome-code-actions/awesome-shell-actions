#!/usr/bin/env bash

function curl-metrics-time () {
    local url=$1
    curl -o /dev/null -s -w 'connect: %{time_connect}s\nstart-trans: %{time_starttransfer}s\ntotal: %{time_total}s\ncode: %{http_code}\nres-size: %{size_download}\n'  $url 
}
