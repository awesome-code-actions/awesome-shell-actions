function git-clone-my-repo() {
  # TODO
  echo ""
}

function github-enable-ssh-over-https() {
  local cfg=$(
    cat <<EOF
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
EOF
  )
  echo "$cfg" | sudo tee /etc/ssh/ssh_config.d/github-ssh-over-https.conf
}

function github-disable-ssh-over-https() {
  rm /etc/ssh/ssh_config.d/github-ssh-over-https.conf || true
}
