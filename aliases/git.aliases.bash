# enable some git aliases
if ! command -v git > /dev/null; then
    return
fi

function _setup_git_aliases() {
    local _conf_exist=0
    [[ -f ~/.gitconfig ]] && _conf_exist=1
    # core
    ! (( _conf_exist )) || ini::filter_by_section core < ~/.gitconfig | ini::get_value_by_key editor > /dev/null && {
        git config --global core.editor 'vi'
    }
    ! (( _conf_exist )) || ini::filter_by_section core < ~/.gitconfig | ini::get_value_by_key pager > /dev/null && {
        git config --global core.pager 'LESS=FRX less -S'
    }
    # merge
    ! (( _conf_exist )) || ini::filter_by_section merge < ~/.gitconfig | ini::get_value_by_key log > /dev/null && {
        git config --global merge.log 'true'
    }
    # help
    ! (( _conf_exist )) || ini::filter_by_section help < ~/.gitconfig | ini::get_value_by_key autocorrect > /dev/null && {
        # automatically correct and execute mistyped commands
        git config --global help.autocorrect '1'
    }
    # alias
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key aliases > /dev/null && {
        # list all git aliases
        git config --global alias.aliases 'config --get-regexp alias'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key last > /dev/null && {
        # show last commit message
        git config --global alias.last 'log -1 HEAD'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key amend > /dev/null && {
        # amend the currently staged files to the latest commit
        git config --global alias.amend 'commit --amend --reuse-message=HEAD'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key update > /dev/null && {
        # fetch all and remove non-existent remote branches
        git config --global alias.update 'fetch --all --prune'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key purge > /dev/null && {
        # remove local tracking branches that do not exist on remote anymore
        git config --global alias.purge '!bash -c "git branch -r | awk '"'{print \\\$1}'"' | grep -E -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '"'{print \\\$1}'"' | xargs -r git branch -D"'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key graph > /dev/null && {
        # show graph of commits
        git config --global alias.graph "log --graph --all --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)%an%Creset %C(yellow)%d%Creset'"
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key uncommit > /dev/null && {
        # undo last commit
        git config --global alias.uncommit 'reset --soft HEAD~1'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key unstage > /dev/null && {
        # removes a file from the index
        git config --global alias.unstage 'reset HEAD --'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key stat > /dev/null && {
        # tracted unstaged file status
        git config --global alias.stat 'diff --stat'
    }
    ! (( _conf_exist )) || ini::filter_by_section alias < ~/.gitconfig | ini::get_value_by_key root > /dev/null && {
        # get the git root dir
        git config --global alias.root 'rev-parse --show-toplevel'
    }
}

_setup_git_aliases
unset -f _setup_git_aliases
