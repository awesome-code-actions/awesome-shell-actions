#!bin/bash
function dns-get() {
  local dns="$1"
  local domain="$2"
  dig @$dns $domain
}
