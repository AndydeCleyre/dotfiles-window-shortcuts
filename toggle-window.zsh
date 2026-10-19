#!/bin/zsh -e

# Dependencies:
#   - procps (pgrep)

# Useful commands:
#   Check a window's class:
#     > kdotool getactivewindow getwindowclassname

# Rationale:
#   - If the chosen app isn't open, launch it
#   - If it's open and not focused, focus it
#   - If it's already focused, minimize it

this=$0

usage () {
  print -rlu2 'Usage:' \
  "  $this LAUNCH_CMD [ WM_CLASS [ CHECK_CMD ] ]" '' \
  '  WM_CLASS and CHECK_CMD each default to the value of LAUNCH_CMD' '' \
  'Examples:' \
  "  $this dolphin org.kde.dolphin" \
  "  $this firefox firefox firefox-bin" \
  "  $this glide-bin glide-glide" \
  "  $this ghostty" \
  "  $this librewolf" \
  "  $this rio" \
  "  $this strawberry" \
  "  $this subl" \
  "  $this Telegram org.telegram.desktop" \
  "  $this wezterm-gui org.wezfurlong.wezterm" \
  "  $this zed dev.zed.Zed zed-editor" \
  "  $this zen-browser zen zen-bin"

  return 1
}

if [[ ! $1 ]] || [[ $1 == --* ]]  usage

launch_cmd=(${(z)1})
wm_class=${2:-$1}
check_cmd=${3:-$1}

if [[ $(kdotool getactivewindow getwindowclassname) == $wm_class ]] {
  kdotool getactivewindow windowminimize
  # TODO: previously focused window
} else {
  kdotool search --class '^'${wm_class//./\\.}'$' windowactivate
}

pgrep -u $USER -x ${check_cmd[1,15]} || exec $launch_cmd &
