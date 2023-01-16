#!/usr/bin/env bash

function zerotier-list-the-link {
    # curl -s -H "Authorization: Bearer ${ZEROTIER_TOKEN}" -H "Content-Type: application/json" "https://my.zerotier.com/api/network/${ZEROTIER_NET}/member" | jq -r '.[]| "\(.name)***\(.config.id)***\(.config.authorized)***\(.config.ipAssignments[0])"' | column -t -s "***" | sort;
    local json=$(curl -s -H "Authorization: Bearer ${ZEROTIER_TOKEN}" -H "Content-Type: application/json" "https://my.zerotier.com/api/network/${ZEROTIER_NET}/member")
	# echo "$json"
	local output=$( bash <<-EOF
	node - <<-START
		let obj=JSON.parse('$json')
		for (let mem of obj) {
            mem.name = mem.name||"unknow"
			console.log(mem.config.id,mem.name,mem.online,mem.config.ipAssignments[0],mem.description)
		}
	START
	EOF
	)
	echo "$output"
  sudo zerotier-cli peers | sudo tail -n +3

}
