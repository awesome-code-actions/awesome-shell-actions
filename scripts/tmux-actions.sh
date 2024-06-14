#!/bin/bash

function tmux-kill-server() {
  tmux kill-server
}
TMUX_DELIMITER=" |-| "
function tmux-set-panel-title() {
  title=$1
  tmux-rename-current-panel $title
}

function tmux-set-window-title() {
  title=$1
  tmux rename-window $title
}

function tmux-rename-current-session() {
  name=$1
  tmux rename-session $name
}

function tmux-rename-current-panel() {
  local name=$1
  tmux set -p @mytitle "$name"
}

function tmux-rename-current-window() {
  name=$1
  tmux rename-window $name
}

function tmux-list-pane() {
  tmux list-panes -s -F "#{session_name}:#{window_name}:#{window_index}:#{pane_title}:#{pane_index}"
}

function tmux-list-pane-current-window() {
  tmux list-panes -s -F "#{session_name}:#{window_name}:#{window_index}:#{pane_title}:#{pane_index}"
}

function tmux-send-key-to-pane() {
  local title="$1"
  shift
  local pane_index=$(tmux-get-paneid $title)
  echo tmux send-keys -t $pane_index "$@"
  tmux send-keys -t $pane_index "$@"
}

function tmux-get-paneid() {
  local title=$1
  tmux-list-current-window-panel | grep $title | cut -d '~' -f 2 | tr -d '\n\r'
}

function tmux-list-current-window-panel() {
  tmux list-panes -t $(tmux-get-current-window-id) -F "#{pane_title}#{pane_index}" | grep '~'
}

function tmux-get-current-window-id() {
  local id=$(tmux list-windows | grep active | cut -d ':' -f 1 | tr -d '\n\r')
  echo $id
}

function tmux-attach-dt() {
  tmux attach -dt $(tmux ls | cut -d ':' -f 1 | fzf)
}

function tmux-kill-this-session() {
  local current_session=$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1 | tr -d '\n\r')
  tmux kill-session -t $current_session
}

function tmux-kill-session() {
  local session=$(tmux ls | cut -d ':' -f 1 | awk '{print $1}' | fzf)
  tmux kill-session -t $session
}

function tmux-jumpto-panel-by-regex() {
  name=$1
  pane=$(tmux-list-panel | grep $name)
  pane_index=${pane##*-}
  target_window_index=$(tmux-list-pane | grep $name | cut -d ':' -f 3)
  current_window_index=$(tmux list-windows | grep '*' | cut -d ':' -f 1)
  # if we are in different window jumpto it first
  if [[ $target_window_index == $current_window_index ]]; then
    tmux select-panel -t $pane_index
  else
    tmux select-window -t $target_window_index && tmux select-panel -t $pane_index
  fi
}

function tmux-edit-config() {
  vim ~/.tmux.conf
}

function tmux-list-all-key() {
  tmux list-keys
}

function tmux-zoom-current-panel() {
  tmux resize-pane -Z
}

function tmux-create-inside-tmux() {
  local name=$1
  tmux new -s "$name" -d
  tmux switch -t $name
}

function tmuxc-kill-other-panel() {
  tmux kill-pane -a
}

function tmuxc-split-right-panel() {
  tmux split-window -h
}

function tmuxc-split-down-panel() {
  tmux split-window
}

function tmuxc-edit-config-file() {
  vim ~/.tmux.conf
}

function tmuxc-select-sessions() {
  local n=$(tmux ls | awk '{print $1}' | tr -d ':' | fzf)
  tmux switch-client -t $n
}

function _tmux-save-pane() (
  cd $SHELL_ACTIONS_BASE/scripts
  ./tmux.py tmux-list-panel
)

function _tmux-save-win() {
  local delimiter="$TMUX_DELIMITER"
  local format
  local format="session_name #{session_name} window_index #{window_index} window_active #{window_active} window_flags :#{window_flags} window_layout #{window_layout}"
  format+="window"
  format+="${delimiter}"
  format+="#{session_name}"
  format+="${delimiter}"
  format+="#{window_index}"
  format+="${delimiter}"
  format+=":#{window_name}"
  format+="${delimiter}"
  format+="#{window_active}"
  format+="${delimiter}"
  format+=":#{window_flags}"
  format+="${delimiter}"
  format+="#{window_layout}"
  tmux list-windows -a -F "$format"
  return
}

function tmux-save-layout() {
  local session=$(tmux list-panes -F "#{session_name}" | head -n 1)
  local layout=""
  layout+=$(_tmux-save-pane)
  layout+="\n"
  layout+=$(_tmux-save-win)
  echo "$layout" >./$session.tmux.layout
  echo "$layout"
  return
}

function tmux-set-ssh() {
  local ssh="$@"
  tmux set -p @myssh "$ssh"
}

function tmux-set-cwd() {
  local mycwd="$@"
  tmux set -p @mycwd "$mycwd"
}

function tmux-load-layout() {
  local layout="$(cat $1)"
  if [[ -z "$layout" ]]; then
    echo "layout is empty"
    return
  fi
  #   echo "$layout" | grep pane
  echo "$layout" | grep pane | _tmux_restore_panel
}

function _tmux_restore_panel() (
  #   function remove_first_char() {
  #     echo "$1" | cut -c2-
  #   }

  #   function new_pane() {
  #     local session_name="$1"
  #     local window_number="$2"
  #     local dir="$3"
  #     local pane_index="$4"
  #     local pane_id="${session_name}:${window_number}.${pane_index}"
  #     # if is_restoring_pane_contents && pane_contents_file_exists "$pane_id"; then
  #     #   local pane_creation_command="$(pane_creation_command "$session_name" "$window_number" "$pane_index")"
  #     #   tmux split-window -t "${session_name}:${window_number}" -c "$dir" "$pane_creation_command"
  #     # else
  #     tmux split-window -t "${session_name}:${window_number}" -c "$dir"
  #     # fi
  #     # minimize window so more panes can fit
  #     tmux resize-pane -t "${session_name}:${window_number}" -U "999"
  #   }
  #   function window_exists() {
  #     local session_name="$1"
  #     local window_number="$2"
  #     tmux list-windows -t "$session_name" -F "#{window_index}" 2>/dev/null |
  #       \grep -q "^$window_number$"
  #   }

  while IFS="$TMUX_DELIMITER" read line_type session_name window_index window_active window_flags pane_index mytitle pane_active myssh mycwd; do
    echo "================"
    # dir="$(remove_first_char "$dir")"
    # pane_full_command="$(remove_first_char "$pane_full_command")"
    # if window_exists "$session_name" "$window_number"; then
    #   new_pane "$session_name" "$window_number" "$dir" "$pane_index"
    # elif session_exists "$session_name"; then
    #   new_window "$session_name" "$window_number" "$dir" "$pane_index"
    # else
    #   new_session "$session_name" "$window_number" "$dir" "$pane_index"
    # fi
    # # set pane title
    # tmux select-pane -t "$session_name:$window_number.$pane_index" -T "$pane_title"
    echo "pane_title: $mytitle mycwd: $mycwd pane_index: $pane_index session_name: $session_name window_number: $window_index"
  done
)
