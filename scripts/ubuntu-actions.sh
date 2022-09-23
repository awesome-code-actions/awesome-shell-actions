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

function ubuntu-21.10-use-mirror {
  sudo sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
  sudo sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
}

function ubuntu-init-start-task {
  echo "#!/usr/bin/bash
notify-send startup
rm ~/.kitty-room/kitty-pop
notify-send 'init kitty ok'
# source ${HOME}/sm/project/awesome-shell-actions/scripts/ubuntu-actions.sh
# random-wallpapaer
# notify-send 'change paper ok'
tmuxp load -d -y /home/cong/sm/ns/share/tmux-note/shell/shell.tmuxp.yaml
notify-send 'change paper init shell ok'
" | sudo tee ${HOME}/sm/app/startup.sh

  sudo chmod a+x ${HOME}/sm/app/startup.sh

  echo "[Desktop Entry]
Name=CustomStartup
Exec=${HOME}/sm/app/startup.sh
Hidden=false
StartupNotify=true
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
Version=1.0
Categories=Utility;" | sudo tee ${HOME}/.config/autostart/customstartup.desktop
}
