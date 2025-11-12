source ~/.config/fish/alias.fish

status --is-interactive; and source (jump shell fish | psub)

# disable greeting, by default it's set to a welcome message
set -g fish_greeting

starship init fish | source
# zoxide is a smarter cs, --cmd cd replaces cd
zoxide init --cmd cd fish | source

if status --is-interactive
    atuin init fish --disable-up-arrow | source
end

set -gx TERMINAL /usr/bin/ghostty
set -gx EDITOR /usr/bin/nvim

set -gx ANDROID_HOME $HOME/Android/Sdk
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path /usr/bin

set -gx OLLAMA_MODELS /home/manish/Desktop/ollama-models
set -gx OLLAMA_FLASH_ATTENTION 1
set -gx OLLAMA_KV_CACHE_TYPE q8_0
set -gx OLLAMA_KEEP_ALIVE -1

set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state

set -gx BAT_THEME "Monokai Extended"

if not pgrep -x ssh-agent > /dev/null
    eval "$(ssh-agent -c)"
end
ssh-add

nvm use latest

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
