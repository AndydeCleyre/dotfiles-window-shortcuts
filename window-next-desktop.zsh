#!/bin/zsh -e

# Dependencies:
#   - kdotool
#   - qdbus6

# Useful Commands:
#   Find window action names (to pass to kwin-do):
#     > qdbus6 org.kde.kglobalaccel /component/kwin shortcutNames

# Rationale:
#   -
#     > This script should only be used when also using
#     > a dynamic virtual desktop script.
#   -
#     > With a dynamic virtual desktop script,
#     > there will always be an empty trailing desktop.
#   -
#     > That means naively sending a window to the next desktop
#     > will *never* wrap back around to the first.
#   -
#     > So if the last desktop is next,
#     > and this window is already
#     > the only one in its origin desktop,
#     > we'll instead send it to desktop number 1.

this=$0
usage () {
  print -rlu2 'Usage:' "  $this"
  return 1
}

if [[ $1 ]]  usage

kwin-do () { qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut $1 }

get-num-windows-on-current-desktop () {
  emulate -L zsh
  local windows=(${(f)"$(kdotool search --desktop $(kdotool get_desktop))"})
  REPLY=$#windows
}

get-switch-action () {
  emulate -L zsh
  local action='Window to Next Desktop'
  local desktop_count=$(kdotool get_num_desktops)
  local desktop_current=$(kdotool get_desktop)
  if (( desktop_current + 1 == desktop_count )) {
    get-num-windows-on-current-desktop
    if (( REPLY == 1 ))  action='Window to Desktop 1'
  }
  REPLY=$action
}

get-switch-action
kwin-do $REPLY
if [[ $REPLY == 'Window to Desktop 1' ]]  kdotool set_desktop 1
