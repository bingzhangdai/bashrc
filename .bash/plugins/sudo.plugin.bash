# https://github.com/Bash-it/bash-it/blob/master/plugins/available/sudo.plugin.bash
# toggle sudo at the beginning of the current or the previous command by hitting the ESC key twice

# Define shortcut keys: [Esc] [Esc]

# Readline library requires bash version 4 or later
if [ "${BASH_VERSINFO}" -ge 4 ]; then
    function sudo-command-line() {
        [[ ${#READLINE_LINE} -eq 0 ]] && READLINE_LINE=$(fc -l -n -1 | xargs)

        if [[ $READLINE_LINE == sudo\ * ]]; then
            READLINE_LINE="${READLINE_LINE#sudo }"
        else
            READLINE_LINE="sudo $READLINE_LINE"
        fi

        READLINE_POINT=${#READLINE_LINE}
    }
    bind -x '"\e\e": sudo-command-line'
fi
