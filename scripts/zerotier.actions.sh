#!/usr/bin/env bash

function zerotier-list-the-link {
  function format_time() (
    local raw=$1
    if [[ -z "$raw" ]]; then
      date +"%Y/%m/%d-%H:%M:%S"
      return
    fi
    date +"%Y/%m/%d-%H:%M:%S" -d @$((raw / 1000))
  )
  local json=$(curl -m 30 -s -H "Authorization: Bearer ${ZEROTIER_TOKEN}" -H "Content-Type: application/json" "https://my.zerotier.com/api/network/${ZEROTIER_NET}/member")
  #   zmx-log "$json"
  local output=$(
    bash <<-EOF
	node - <<-START
		let obj=JSON.parse('$json')
		for (let mem of obj) {
            mem.name = mem.name||"unknow"
			console.log(mem.config.id,mem.name,mem.online,mem.config.ipAssignments[0],mem.description,mem.lastOnline,mem.lastSeen)
		}
	START
	EOF
  )
  local out="$output"
  local my=$(sudo zerotier-cli info | awk '{print $3}')
  local peers=$(sudo zerotier-cli peers | sudo tail -n +3)
  while read -r p; do
    local id=$(echo "$p" | awk '{print $1}' | xargs)
    local lat=$(echo "$p" | awk '{print $4}' | xargs)
    local link=$(echo "$p" | awk '{print $5}')
    local info=$(echo "$out" | grep $id)
    local name=$(echo "$info" | awk '{print $2}' | xargs)
    if [[ -z "$name" ]]; then
      continue
    fi
    local ip=$(echo "$info" | awk '{print $4}' | xargs)
    local last_online=$(echo "$info" | awk '{print $5}' | xargs)
    local last_seen=$(echo "$info" | awk '{print $6}' | xargs)
    echo "$name $ip $id $link $lat $(format_time $last_online) $(format_time $last_seen)"
  done < <(echo "$peers")
  local info=$(echo "$out" | grep $my)
  local ip=$(echo "$info" | awk '{print $4}' | xargs)
  local name=$(echo "$info" | awk '{print $2}' | xargs)
  echo "$name $ip $my my 0 0 $(format_time) $(format_time)"
}
