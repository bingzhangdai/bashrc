# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).

if ! shopt -oq posix; then
    if [ -r /usr/share/bash-completion/bash_completion ]; then
        builtin source /usr/share/bash-completion/bash_completion
    elif [ -r /etc/bash_completion ]; then
        builtin source /etc/bash_completion
    # some distribution makes use of a profile.d script to import completion.
    elif [ -r /etc/profile.d/bash_completion.sh ]; then
        builtin source /etc/profile.d/bash_completion.sh
    # homebrew
    # bash_completion@2
    elif [ -r "$_BREW_PREFIX"/etc/profile.d/bash_completion.sh ]; then
        builtin source "$_BREW_PREFIX"/etc/profile.d/bash_completion.sh
    # bash_completion@1
    elif [ -r "$_BREW_PREFIX"/etc/bash_completion ]; then
        builtin source "$_BREW_PREFIX"/etc/bash_completion
    fi
fi

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

# ignore private & protected functions
if [ "${BASH_VERSINFO}" -ge 5 ]; then
    function _bash_command_complete() {
        local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"
        if [ -z "$CURRENT_PROMPT" ]; then
            return
        fi

        local candidates=( $(compgen -c -- "$CURRENT_PROMPT") )

        if [[ "$CURRENT_PROMPT" =~ ^[^\.^:]+[\.:]*$ ]]; then
            # log log. log::
            local i
            for i in "${candidates[@]}"; do
                [[ ! "$i" =~ ^[^\.^:]+[\.:]+_.*$ ]] && arr.add COMPREPLY "$i"
            done
        else
            for i in "${candidates[@]}"; do
                # add trailing slashes
                [[ -d "$i" ]] && arr.add COMPREPLY "$i"/ || arr.add COMPREPLY "$i"
            done
        fi
        [[ -d "${candidates[0]}" ]] && compopt -o nospace
    }

  complete -o default -I -F _bash_command_complete
fi

_time_completion=$(complete -p time 2> /dev/null)
[[ -n "$_time_completion" ]] && $_time_completion benchmark
unset _time_completion
