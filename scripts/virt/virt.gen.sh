#!/bin/bash
function virt-list-vm() (
  PYTHONPATH="$PYTHONPATH:/home/cong/sm/project/awesome-shell-actions/scripts" python3 -m virt virt.list-vm $@
)
function virt-stop-vm() (
  PYTHONPATH="$PYTHONPATH:/home/cong/sm/project/awesome-shell-actions/scripts" python3 -m virt virt.stop-vm $@
)
