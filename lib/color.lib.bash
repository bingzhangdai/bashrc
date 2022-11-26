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

function color::truecolor() {
    [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]
}

function color::256() {
    # tput setaf $1
    printf -- "\e[38;5;${1}m"
}

if color::truecolor; then
    function color::hex() {
        local hex=${1#"#"}
        local r=${hex:0:2} g=${hex:2:2} b=${hex:4:2}
        r=$((16#${r}))
        g=$((16#${g}))
        b=$((16#${b}))
        printf -- "\e[38;2;${r};${g};${b}m"
    }
else
    function color::hex() {
        color::256 $(color::hex_to_256 "$1")
    }

    # 256 Colors Cheat Sheet
    # https://www.ditig.com/256-colors-cheat-sheet
    function color::hex_to_256() {
        local hex=${1#"#"}
        local r=${hex:0:2} g=${hex:2:2} b=${hex:4:2}
        r=$((16#${r}))
        g=$((16#${g}))
        b=$((16#${b}))
        color::rgb_to_256 $r $g $b
    }

    # region https://github.com/tmux/tmux/blob/dae2868d1227b95fd076fb4a5efa6256c7245943/colour.c#L57
    # TODO: test: https://gist.github.com/MicahElliott/719710
    function color::_color_dist_sq() {
        local R=$1 G=$2 B=$3 r=$4 g=$5 b=$6
        echo $(( (R - r) * (R - r) + (G - g) * (G - g) + (B - b) * (B - b) ))
    }

    function color::_colour_to_6cube() {
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

    function color::rgb_to_256() {
        local r=$1 g=$2 b=$3
        local qr=$(color::_colour_to_6cube $r) qg=$(color::_colour_to_6cube $g) qb=$(color::_colour_to_6cube $b)
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
        local d=$(color::_color_dist_sq $cr $cg $cb $r $g $b)
        local gd=$(color::_color_dist_sq $grey $grey $grey $r $g $b)
        local idx
        if (( gd < d )); then
            idx=$(( 232 + grey_idx ))
        else
            idx=$(( 16 + (36 * qr) + (6 * qg) + qb ))
        fi

        echo $idx
    }

    # endregion
fi

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

    # monokai
    # ref: https://github.com/microsoft/vscode/blob/main/extensions/theme-monokai/themes/monokai-color-theme.json
    # Palette       Hex Code
    # Background    #272822
    # Foreground    #F8F8F2
    # Comment       #75715E
    # Red           #F92672
    # Orange        #FD971F
    # Light Orange  #E69F66
    # Yellow        #E6DB74
    # Green         #A6E22E
    # Blue          #66D9EF
    # Purple        #AE81FF
    ORANGE=$(color::hex "#FD971F")
    BLACK=$(color::hex "#272822") # background
    YELLOW=$(color::hex "#E6DB74")
    PURPLE=$(color::hex "#AE81FF")
    BLUE=$(color::hex "#66D9EF")
    GREEN=$(color::hex "#A6E22E")
    RED=$(color::hex "#F92672")
    WHITE=$(color::hex "#F8F8F2") # foreground
    BLACK_B=$(color::hex "#75715E") # comment
fi

