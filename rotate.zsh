#!/bin/zsh -e

# Dependencies:
#   - karousel
#   - kdotool
#   - qdbus6

# Optional Dependencies:
#   - toast-panel.zsh
#   - window-next-desktop.zsh

# Useful Commands:
#   Find window action names (to pass to kwin-do):
#     > qdbus6 org.kde.kglobalaccel /component/kwin shortcutNames

# Rationale:
#   - Rotate 3 fingers (2+thumb) to move a floating window to an adjacent desktop
#   - Rotate 3 fingers (2+thumb) to move a column to the left or right
#   - Rotate 4 fingers (3+thumb) to move a window into, out of, or within a column shared with another window

this=$0
usage () {
  print -rlu2 'Usage:' "  $this 3|4 CLOCKWISE|COUNTERCLOCKWISE"
  return 1
}

fingers=$1
direction=$2
if [[ $fingers != (3|4) ]] || [[ $direction != (|COUNTER)CLOCKWISE ]]  usage

kwin-do () { qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut $1 }

minimap () { if [[ -x ${this:a:h}/toast-panel.zsh ]]  ${this:a:h}/toast-panel.zsh $@ }

floating=
window_data=$(kdotool kwinscript --inline '
var w = workspace.activeWindow;
if (w) {
    output_result("BELOW=" + w.keepBelow + " FULLSCREEN=" + w.fullScreen);
} else {
    output_result("No active window");
}
')
if [[ $window_data != *(BELOW|FULLSCREEN)=true* ]]  floating=1

DYNAMIC_DESKTOPS_ON=1
window-next-desktop () {
  if [[ $DYNAMIC_DESKTOPS_ON ]] && [[ -x ${this:a:h}/window-next-desktop.zsh ]] {
    ${this:a:h}/window-next-desktop.zsh
  } else {
    kwin-do 'Window to Next Desktop'
  }
}

if [[ $floating ]] {
  if [[ $direction == CLOCKWISE ]] {
    window-next-desktop
  } else {
    kwin-do 'Window to Previous Desktop'
  }
} elif [[ $fingers == 3 ]] {
  if [[ $direction == CLOCKWISE ]] {
    kwin-do karousel-column-move-right
  } else {
    kwin-do karousel-column-move-left
  }
} elif [[ $fingers == 4 ]] {
  if [[ $direction == CLOCKWISE ]] {
    kwin-do karousel-window-move-next
  } else {
    kwin-do karousel-window-move-previous
  }
}

minimap toast &
