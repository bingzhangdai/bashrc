# ignoreboth: don't put duplicate lines or lines starting with space in the history.
# erasedups:  eliminate duplicates across the whole history
# autoshare: automatically share history between multiple running shells
HISTCONTROL=ignoreboth:erasedups:autoshare

# HISTTIMEFORMAT='%F %T '

# Ignore these commands
[[ -z "$HISTIGNORE" ]] && HISTIGNORE="\
&:[ ]*
exit:reload:rl
ls:l:ll:la
j:pwd:z
bg:fg
history:rh:clear:cls
kill
true:false
"
HISTIGNORE=${HISTIGNORE%$'\n'}
HISTIGNORE=${HISTIGNORE//$'\n'/:}

# append to the history file, don't overwrite it
shopt -s histappend

# save all lines of a multiple-line command in the same history entry.
shopt -s cmdhist
shopt -u lithist

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

# https://unix.stackexchange.com/questions/18212/bash-history-ignoredups-and-erasedups-setting-conflict-with-common-history
# store history immediately
# PROMPT_COMMAND="$PROMPT_COMMAND (history -a);"

function rh {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
