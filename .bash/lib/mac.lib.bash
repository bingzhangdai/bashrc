function _is_on_mac() {
    [[ $OSTYPE == 'darwin'* ]]
}

# store the homebrew prefix, avoid unncessary calls of brew command
command -v brew > /dev/null && _brew_prefxi="$(brew --prefix)"
