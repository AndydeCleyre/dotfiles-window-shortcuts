#!/bin/zsh -e

# Dependencies:
#   - karousel
#   - kdotool
#   - qdbus6

# Optional Dependencies:
#   - toast-panel.zsh

# Useful Commands:
#   Find window action names (to pass to kwin-do):
#     > qdbus6 org.kde.kglobalaccel /component/kwin shortcutNames

this=$0
minimap () { if [[ -x ${this:a:h}/toast-panel.zsh ]]  ${this:a:h}/toast-panel.zsh $@ }

usage () {
  print -rlu2 'Usage:' "  $this [--shift|--swipe|--pinch] RIGHT|LEFT|UP|DOWN|SPACE|X"
  return 1
}

# -- Parse arguments --

if [[ $1 != (--(shift|swipe|pinch)|RIGHT|LEFT|UP|DOWN|SPACE|X) ]]  usage

shift=
swipe=
pinch=
if [[ $1 == --shift ]] {
  shift=1
  shift
} elif [[ $1 == --swipe ]] {
  swipe=1
  shift
} elif [[ $1 == --pinch ]] {
  pinch=1
  shift
}

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

direction=$1
if [[ $direction != (RIGHT|LEFT|UP|DOWN|SPACE|X) ]]  usage

# -- Define kwin action helper, kwin-do --

kwin-do () { qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut $1 }

# -- Handle non-directions (SPACE, X) --

if [[ $direction == SPACE ]] {
  if [[ $floating ]] {
    kwin-do 'Window Maximize Horizontal'
  } else {
    kwin-do karousel-cycle-preset-widths
  }
  return
}

if [[ $direction == X ]] {
  if [[ $floating ]] {
    kwin-do 'Window Maximize Vertical'
  } else {
    kwin-do karousel-column-toggle-stacked
  }
  return
}

# -- Reverse direction for a tiled swipe --

if [[ ! $floating ]] && [[ $swipe ]] {
  case $direction {
    RIGHT) direction=LEFT  ;;
    LEFT)  direction=RIGHT ;;
    UP)    direction=DOWN  ;;
    DOWN)  direction=UP    ;;
  }
}

# -- Define some actions using kwin-do: focus, move, resize --

karousel-focus () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do karousel-focus-next     ;;
    DOWN)  kwin-do karousel-focus-next     ;;
    LEFT)  kwin-do karousel-focus-previous ;;
    UP)    kwin-do karousel-focus-previous ;;
    # UP)    kwin-do 'Switch Window Up'      ;;
    # DOWN)  kwin-do 'Switch Window Down'    ;;
  }
}

karousel-move () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do karousel-column-move-${(L)1} ;;
    LEFT)  kwin-do karousel-column-move-${(L)1} ;;
    UP)    kwin-do karousel-window-move-${(L)1} ;;
    DOWN)  kwin-do karousel-window-move-${(L)1} ;;
  }
}

karousel-resize () {  # RIGHT|LEFT
  case $1 {
    RIGHT) kwin-do karousel-column-width-increase ;;
    LEFT)  kwin-do karousel-column-width-decrease ;;
  }
}

kwin-move () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do "Window Pack ${(C)1}" ;;
    LEFT)  kwin-do "Window Pack ${(C)1}" ;;
    UP)    kwin-do "Window Pack ${(C)1}" ;;
    DOWN)  kwin-do "Window Pack ${(C)1}" ;;
  }
}

kwin-resize () {  # RIGHT|LEFT|UP|DOWN
  case $1 {
    RIGHT) kwin-do 'Window Grow Horizontal'   ;;
    LEFT)  kwin-do 'Window Shrink Horizontal' ;;
    UP)    kwin-do 'Window Shrink Vertical'   ;;
    DOWN)  kwin-do 'Window Grow Vertical'     ;;
  }
}

# -- Do the thing --

if [[ $floating ]] {
  if [[ $shift || $pinch ]] {
    kwin-resize $direction
  } else {
    kwin-move $direction
  }
} else {
  if [[ $shift ]] {
    minimap toast &
    karousel-move $direction
  } elif [[ $pinch ]] {
    karousel-resize $direction
  } else {
    minimap toast &
    karousel-focus $direction
  }
}
