## prompt: user@host:/path/to/dir(git_branch)$ 

# set 'yes' for a colored prompt, if the terminal has the capability
OPT_ENABLE_COLOR=yes

# set 'yes' to add git information to the prompt
OPT_ENABLE_GIT_BRANCH=yes

# set 'yes' to enable abbreviated working directory in your command prompt
# by default the each directory will be shortened to one character
# e.g. /path/to/current/directory -> /p/t/c/directory
OPT_ENABLE_SHORT_PATH=yes
# set 'yes' to shrink the each directory name to the shortest unambiguous prefix
OPT_UNAMBIGUOUS_SHORT_PATH=yes

# hostname will become red if the battery is below `OPT_BATTER_THRESHOLD`
# run battery::value the get the current percentage
OPT_ENABLE_BATTERY_COLOR=yes
# battery below 20% will considered low
OPT_BATTER_THRESHOLD=20

# set 'yes' to enable auto update
OPT_ENABLE_AUTO_UPDATE=yes
# prompt for update every 30 days
OPT_AUTO_UPDATE_PERIOD=30
