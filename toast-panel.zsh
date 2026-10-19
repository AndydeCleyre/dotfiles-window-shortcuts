#!/bin/zsh -e

# Dependencies:
#   - qdbus6

# Rationale:
#   - Briefly raise a panel, to reveal a "minimap" of the window columns (task manager applet)

# -- Defaults --
PANEL_IDX=1,2

# -- Usage --
this=$0
usage () {
  print -rlPu2 '%F{blue}Usage:%f' "  %F{green}%B${this}%b%f [%F{yellow}-p%f <PANEL_INDEX>%F{blue}=1,2%f] %F{green}show%f|%F{green}hide%f|%F{green}toast%f [<SECONDS>%F{blue}=1.25%f]"
  return 1
}

# -- Args --
if [[ $1 == -p ]] {
  PANEL_IDX=$2
  shift 2
}

# -- Panel Operations --
zmodload zsh/stat zsh/zselect

panel-viz-set () {  # <panel-idx> show|hide
  emulate -L zsh
  
  local panel_idx=$1
  shift

  local viz=$1
  
  case $viz {
    (show) 
	    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "panels()[$panel_idx].hiding = \"windowsgobelow\""
    ;; (hide) 
	    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "panels()[$panel_idx].hiding = \"dodgewindows\""
    ;; (*)
      usage ;;
  }  
}

panel-viz-toast () {  # <panel-idx> [<seconds>=1.25]
  emulate -L zsh

  if ! [[ $1 ]]  return
  local panel_idx=$1
  shift

  local seconds=1.25
  if [[ $1 ]]  seconds=$1
  if (( seconds < 1 ))  seconds=1

  integer centiseconds=$(( seconds * 100 ))

  local panel_shown_file=${TMPPREFIX}.${panel_idx}.shown
  panel-viz-set $panel_idx show
  # touch $PANEL_SHOWN_FILE
  <<<'' >$panel_shown_file

  zselect -t $centiseconds || true

  local now=${(%):-%D{%s.%N}}
  local shown_at=$(zstat -F %s.%N +mtime $panel_shown_file)
  if [[ $shown_at ]] && (( (now - shown_at) >= seconds ))  panel-viz-set $panel_idx hide
}

# -- Main --
autoload -Uz zargs

case $1 {
  show|hide)
    zargs -P 12 -i___ -- ${(s:,:)PANEL_IDX} -- panel-viz-set ___ $1   ;;
  toast)
    zargs -P 12 -i___ -- ${(s:,:)PANEL_IDX} -- panel-viz-toast ___ $1 ;;
  *) usage ;;
}
