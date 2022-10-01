# better top, glances is better than htop
# on wsl: https://github.com/nicolargo/glances/issues/1485
# pip3 install --upgrade glances
# pip3 install --upgrade psutil
if command -v glances > /dev/null; then
    alias top='glances'
elif command -v htop > /dev/null; then
    alias top='htop'
fi
