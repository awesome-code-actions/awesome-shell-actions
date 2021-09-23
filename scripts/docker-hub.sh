dockerhub-list-tags() {
	# @arg-len: 1
	# @category: glasses

	local name=$1
	wget -q https://registry.hub.docker.com/v1/repositories/$name/tags -O -  | jq -r '.[].name'
}