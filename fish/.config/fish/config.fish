source ~/.config/fish/alias.fish

# Configure Jump
status --is-interactive; and source (jump shell fish | psub)

# disable greeting, by default it's set to a welcome message
set -g fish_greeting

# Install Starship
starship init fish | source

set -g EDITOR /usr/bin/vim

set -x ANDROID_HOME $HOME/Android/Sdk
set -x PATH $PATH $ANDROID_HOME/emulator
set -x PATH $PATH $ANDROID_HOME/platform-tools
set -x PATH $PATH /usr/bin/

eval "$(ssh-agent -c)"
ssh-add
