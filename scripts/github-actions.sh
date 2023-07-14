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
  echo "$cfg" > ~/.ssh/config.d/github-ssh-over-https
}

function github-enable-ssh-over-https() {
