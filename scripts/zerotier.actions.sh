#!/usr/bin/env bash

function zerotier-list-the-link {
    # curl -s -H "Authorization: Bearer ${ZEROTIER_TOKEN}" -H "Content-Type: application/json" "https://my.zerotier.com/api/network/${ZEROTIER_NET}/member" | jq -r '.[]| "\(.name)***\(.config.id)***\(.config.authorized)***\(.config.ipAssignments[0])"' | column -t -s "***" | sort;
    local json=$(curl -s -H "Authorization: Bearer ${ZEROTIER_TOKEN}" -H "Content-Type: application/json" "https://my.zerotier.com/api/network/${ZEROTIER_NET}/member")
	# echo "$json"
	local output=$( bash <<-EOF
	node - <<-START
		let obj=JSON.parse('$json')
		for (let mem of obj) {
			if (mem.name =="") {
				continue
			}
			console.log(mem.name,mem.online,mem.config.ipAssignments)
		}
	START
	EOF
	)
	echo $output
}