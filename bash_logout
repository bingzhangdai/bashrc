# ~/.bash_logout: executed by bash(1) when login shell exits.
set -o pipefail

# shrink bash history, remove duplicates whiling keeping the order
if command -v nl > /dev/null; then
    nl ~/.bash_history | LC_ALL='C' sort -k 2  -k 1,1nr | uniq -f 1 | sort -n | cut -f 2 >| ~/.bash_history~ && \
    mv ~/.bash_history~ ~/.bash_history
fi

# debug
[[ $? -ne 0 ]] && read -p "an error occurred, press enter to continue..."

rm -rf ~/.z.*

# when leaving the console clear the screen to increase privacy
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi
