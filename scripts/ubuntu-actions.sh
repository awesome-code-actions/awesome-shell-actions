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
	echo "abs path $abs_path"
	gsettings set org.gnome.desktop.background picture-uri file:///"$abs_path"
}