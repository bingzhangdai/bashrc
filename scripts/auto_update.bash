# check for update
if [[ "$OPT_ENABLE_AUTO_UPDATE" == yes ]]; then
    : ${OPT_AUTO_UPDATE_PERIOD:=30}
    function __prompt_update() (
        local _file=${_DOT_BASH_BASEDIR}/cache/update_history
        local _timestamp; printf -v _timestamp '%(%s)T' '-1'

        [[ -r "$_file" ]] && source "$_file"
        ! (( last_updated_timestamp )) && {
            __write_update_record
            return
        }

        if (( last_updated_timestamp + OPT_AUTO_UPDATE_PERIOD * 24 * 3600 < _timestamp )); then
            local _update
            read -p "Update your bashrc?[Y/N] " _update
            if [[ "$_update" == Y ]]; then
                bash -c "$(curl -fsSL https://raw.githubusercontent.com/bingzhangdai/bashrc/main/scripts/install)"
                __write_update_record
            fi
        fi
    )

    function __write_update_record() {
        local _file=${_DOT_BASH_BASEDIR}/cache/update_history
        local _timestamp; printf -v _timestamp '%(%s)T' '-1'
        [[ ! -e "$_file" ]] && touch "$_file"
        echo "last_updated_timestamp=$_timestamp;" >| "$_file"
    }

    __prompt_update
    unset -f __write_update_record __prompt_update
fi
