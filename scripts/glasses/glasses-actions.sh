#!/usr/bin/env bash
function which-dns() {
    nmcli dev show | grep DNS
}
