pragma_once

# set a fancy prompt (non-color, unless we know we "want" color)
_color_prompt=
if [ -n "$color_prompt" ]; then
  # set a fancy prompt (non-color, unless we know we "want" color)
  case "$TERM" in
    xterm-*color)
      _color_prompt=yes
      ;;
  *)
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
      # We have color support; assume it's compliant with Ecma-48
      # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
      # a case would tend to support setf rather than setaf.)
      _color_prompt=yes
    fi
    ;;
  esac
fi

# region https://github.com/tmux/tmux/blob/dae2868d1227b95fd076fb4a5efa6256c7245943/colour.c#L57
# TODO: test: https://gist.github.com/MicahElliott/719710
function _color_dist_sq() {
  local R=$1 G=$2 B=$3 r=$4 g=$5 b=$6
  echo $(( (R - r) * (R - r) + (G - g) * (G - g) + (B - b) * (B - b) ))
}

function _colour_to_6cube() {
    local v="$1"
    if (( v < 48 )); then
      echo 0
    elif (( v < 114 )); then
      echo 1
    else
      echo $(( (v - 35) / 40 ))
    fi
}

_q2c=(0x00 0x5f 0x87 0xaf 0xd7 0xff)

function rgb_to_256() {
  local r=$1 g=$2 b=$3
  local qr=$(_colour_to_6cube $r) qg=$(_colour_to_6cube $g) qb=$(_colour_to_6cube $b)
  local cr=${_q2c[$qr]} cg=${_q2c[$qg]} cb=${_q2c[$qb]}

  # if we have hit the colour exactly, return early.
  if (( cr == $r && cg == $g && cb == $b )); then
    echo $(( 16 + (36 * qr) + (6 * qg) + qb ))
    return
  fi

  # work out the closest grey (average of rgb)
  local grey_avg=$(( (r + g + b) / 3 )) grey_idx grey
  if (( grey_avg > 238 )); then
    grey_idx=23
  else
    grey_idx=$(( (grey_avg - 3) / 10 ))
  fi
  grey=$(( 8 + (10 * grey_idx) ))

  # is grey or 6x6x6 colour closest?
  local d=$(_color_dist_sq $cr $cg $cb $r $g $b)
  local gd=$(_color_dist_sq $grey $grey $grey $r $g $b)
  local idx
  if (( gd < d )); then
    idx=$(( 232 + grey_idx ))
  else
    idx=$(( 16 + (36 * qr) + (6 * qg) + qb ))
  fi

  echo $idx
}

# endregion

# 256 Colors Cheat Sheet
# https://www.ditig.com/256-colors-cheat-sheet
function hex_to_256() {
    local hex=${1#"#"}
    local r=${hex:0:2} g=${hex:2:2} b=${hex:4:2}
    r=$((16#${r}))
    g=$((16#${g}))
    b=$((16#${b}))
    rgb_to_256 $r $g $b
}

# http://wiki.bash-hackers.org/scripting/terminalcodes
# https://gist.github.com/vratiu/9780109
# https://mybatis.org/migrations/xref/org/apache/ibatis/migration/ConsoleColors.html
if [ -n "$_color_prompt" ]; then
  NONE=$'\033[00m'

  # regular colors
  BLACK=$'\033[0;30m'
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'
  PURPLE=$'\033[0;35m'
  CYAN=$'\033[0;36m'
  WHITE=$'\033[0;37m'
  ORANGE=$'\033[38;5;202m'

  # bold
  BLACK_B=$'\033[1;30m'
  RED_B=$'\033[1;31m'
  GREEN_B=$'\033[1;32m'
  YELLOW_B=$'\033[1;33m'
  BLUE_B=$'\033[1;34m'
  PURPLE_B=$'\033[1;35m'
  CYAN_B=$'\033[1;36m'
  WHITE_B=$'\033[1;37m'

  # underlined
  BLACK_U=$'\033[4;30m'
  RED_U=$'\033[4;31m'
  GREEN_U=$'\033[4;32m'
  YELLOW_U=$'\033[4;33m'
  BLUE_U=$'\033[4;34m'
  PURPLE_U=$'\033[4;35m'
  CYAN_U=$'\033[4;36m'
  WHITE_U=$'\033[4;37m'

  # background
  BLACK_BG=$'\033[40m'
  RED_BG=$'\033[41m'
  GREEN_BG=$'\033[42m'
  YELLOW_BG=$'\033[43m'
  BLUE_BG=$'\033[44m'
  PURPLE_BG=$'\033[45m'
  CYAN_BG=$'\033[46m'
  WHITE_BG=$'\033[47m'

  # high intensity
  BLACK_BRT=$'\033[0;90m'
  RED_BRT=$'\033[0;91m'
  GREEN_BRT=$'\033[0;92m'
  YELLOW_BRT=$'\033[0;93m'
  BLUE_BRT=$'\033[0;94m'
  PURPLE_BRT=$'\033[0;95m'
  CYAN_BRT=$'\033[0;96m'
  WHITE_BRT=$'\033[0;97m'

  # bold high intensity
  BLACK_B_BRT=$'\033[1;90m'
  RED_B_BRT=$'\033[1;91m'
  GREEN_B_BRT=$'\033[1;92m'
  YELLOW_B_BRT=$'\033[1;93m'
  BLUE_B_BRT=$'\033[1;94m'
  PURPLE_B_BRT=$'\033[1;95m'
  CYAN_B_BRT=$'\033[1;96m'
  WHITE_B_BRT=$'\033[1;97m'

 # high intensity backgrounds
  BLACK_BG_BRT=$'\033[0;100m'
  RED_BG_BRT=$'\033[0;101m'
  GREEN_BG_BRT=$'\033[0;102m'
  YELLOW_BG_BRT=$'\033[0;103m'
  BLUE_BG_BRT=$'\033[0;104m'
  PURPLE_BG_BRT=$'\033[0;105m'
  CYAN_BG_BRT=$'\033[0;106m'
  WHITE_BG_BRT=$'\033[0;107m'

  if tput setaf 1 &>/dev/null; then
    NONE=$(tput sgr0)
    # monokai
    # ref: https://github.com/microsoft/vscode/blob/main/extensions/theme-monokai/themes/monokai-color-theme.json
    ORANGE=$(tput setaf $(hex_to_256 "#FD971F"))
    BLACK=$(tput setaf $(hex_to_256 "#272822")) # background
    YELLOW=$(tput setaf $(hex_to_256 "#E6DB74"))
    PURPLE=$(tput setaf $(hex_to_256 "#AE81FF"))
    BLUE=$(tput setaf $(hex_to_256 "#66D9EF"))
    GREEN=$(tput setaf $(hex_to_256 "#A6E22E"))
    RED=$(tput setaf $(hex_to_256 "#F92672"))
    WHITE=$(tput setaf $(hex_to_256 "#F8F8F2")) # foreground
    BLACK_B=$(tput setaf $(hex_to_256 "#75715E")) # comment
  fi
fi

