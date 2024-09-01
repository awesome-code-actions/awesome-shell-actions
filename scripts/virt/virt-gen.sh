#!/bin/bash

function virt-call() {
  PYTHONPATH="$PYTHONPATH:$HOME/sm/project/awesome-shell-actions/scripts" python3 -m virt
}

function virt-gen() {
  local cmd=$(
    cat <<EOF
#!/bin/bash
EOF
  )
  for t in $(virt-call -l | grep virt); do
    local invoke_task_name=$t
    local bash_fn_name=$(echo "$t" | sed 's/\./-/')
    echo "t $t $normal xx"
    local fn=$(
      cat <<EOF
function $bash_fn_name() (
  PYTHONPATH="\$PYTHONPATH:$SHELL_ACTIONS_BASE/scripts" python3 -m virt $invoke_task_name \$@
)
EOF
    )
    cmd=$(cat <<EOF
$cmd
$fn
EOF
)
  done
  echo "$cmd" >$SHELL_ACTIONS_BASE/scripts/virt/virt.gen.sh
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "start gen"
    virt-gen "$@"
fi
