function random-wallpapaer {
	if [ -z "$WALLPAPERS" ]; then
		echo "give a wallpapaers path"
		exit
	fi
	cd $WALLPAPERS
	local p=$(ls | shuf -n 1)
	echo "random wallpapaer is $p"
	set-wallpapaer "./$p"
}

function set-wallpapaer {
	local p=$1
	local abs_path=$(realpath $1)
	local p="$abs_path"
	echo "abs path $p"

	gsettings set org.gnome.desktop.background picture-uri "$p"
}
