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
    elif [ -r "$_brew_prefxi"/etc/profile.d/bash_completion.sh ]; then
        builtin source "$_brew_prefxi"/etc/profile.d/bash_completion.sh
    # bash_completion@1
    elif [ -r "$_brew_prefxi"/etc/bash_completion ]; then
        builtin source "$_brew_prefxi"/etc/bash_completion
    fi
fi

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}
