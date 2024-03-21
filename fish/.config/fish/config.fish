source ~/.config/fish/alias.fish

# Configure Jump
status --is-interactive; and source (jump shell fish | psub)

# disable greeting, by default it's set to a welcome message
set -g fish_greeting

# Install Starship
starship init fish | source

set -g EDITOR /usr/bin/vim
