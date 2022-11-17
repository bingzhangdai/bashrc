[[ -r /etc/debian_chroot ]] && debian_chroot="$(</etc/debian_chroot)"

function term::set_title() {
    [[ "$PS1" =~ \\\[\\e\]0\;.*\\a\\\](.*) ]] && PS1=${BASH_REMATCH[1]}
    PS1='\[\e]0;'"$1"'\a\]'"$PS1"
}

function term::is_ssh() {
    [[ -n "${SSH_CLIENT-}${SSH2_CLIENT-}${SSH_TTY-}" ]]
}

function term::is_telnet() {
    [[ -n ${REMOTEHOST-} ]]
}

function term::is_local() {
    ! term::is_ssh && ! term::is_telnet
}
