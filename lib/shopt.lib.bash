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

# If set, local variables inherit the value and attributes 
# of a variable of the same name that exists at a previous 
# scope before any new value is assigned. The nameref 
# attribute is not inherited.
# if (( BASH_VERSINFO >= 5 )); then
#     shopt -s localvar_inherit
# fi
