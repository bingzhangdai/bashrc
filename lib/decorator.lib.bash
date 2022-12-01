# Suppress the return value of the given function
#
# example:
#   @no_return some_function
function @no_return() {
    # random number to avoid conflicts
    local _inner_fun=__${FUNCNAME[0]:1}_wrapper_${RANDOM}_$1
    fun::rename $1 $_inner_fun
    eval "
        function $1() {
            local _exit=\$?
            $_inner_fun \$@
            return \$_exit
        }
    "
}

# Create a public function of given (inner) function.
# The (inner) function's first argument should be the return value
#
# usage: @create_public_fun _inner_fun
#   public function is inner_fun
#
# example:
#   @create_public_fun _inner_fun -> inner_fun
#   @create_public_fun git::_branch -> git::branch
#   @create_public_fun logger._get_current_time -> logger.get_current_time
function @create_public_fun() {
    if ! fun::is_function "$1"; then
        logger.log ERROR "no such function $1."
        return 1
    fi

    [[ $1 =~ ^_([^_][^:.]+)$ ]] || [[ $1 =~ ^([^_][^:.]+)(::|\.)_([^_][^:.]+)$ ]] || {
        logger.log ERROR "wrong fuction format: $1"
        return 1
    }

    eval "
        function ${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]} () {
            local _val
            $1 _val \$@
            local _exit=\$?
            [[ -n \"\$_val\" ]] && printf -- \"\$_val\"
            return \$_exit
        }
    "
}
