# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# recursive globbing, e.g. `echo **/*.txt`
shopt -s globstar
