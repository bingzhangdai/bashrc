# This defines where cd looks for targets
# Add the directories you want to have fast access to, separated by colon
# Ex: CDPATH=".:~:~/projects" will look for targets in the current working directory, in home and in the ~/projec
# CDPATH=".:~"

# `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
shopt -s autocd

# correct spelling errors during tab-completion
shopt -s dirspell

# autocorrect typos in path names when using `cd`
shopt -s cdspell;

# do not replace directory names with the results of word expansion when performing filename completion
# shopt -u direxpand

# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
# shopt -s cdable_vars
