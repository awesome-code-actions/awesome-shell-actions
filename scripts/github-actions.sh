function git-clone-my-repo() {
  # TODO
  echo ""
}

function git-() {
  local cfg=$(
    cat <<EOF
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
EOF
  )
  echo $cfg

}
