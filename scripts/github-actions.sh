function git-clone-my-repo() {
  # TODO
  echo ""
}

function github-use-ssh-over-https() {
  local cfg=$(
    cat <<EOF
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
EOF
  )
  echo $cfg > ~/.ssh/config

}
