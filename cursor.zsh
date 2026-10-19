#!/bin/zsh -e

# Dependencies:
#   - ydotool or xdotool

this=$0
usage () {
  print -rlu2 -- 'Usage:' "  $this RIGHT|LEFT|UP|DOWN"
  return 1
}

local xdelta=0 ydelta=0
case $1 {
  RIGHT)  xdelta=30  ;;
  DOWN)   ydelta=30  ;;
  LEFT)   xdelta=-30 ;;
  UP)     ydelta=-30 ;;
  *)      usage      ;;
}

if [[ $WAYLAND_DISPLAY ]] {
  ydotool mousemove -- $xdelta $ydelta
} else {  
  xdotool mousemove_relative -- $xdelta $ydelta
}
