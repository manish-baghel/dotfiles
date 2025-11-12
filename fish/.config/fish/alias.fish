alias reload='exec fish'
alias bb="sudo bleachbit --clean system.cache system.localizations system.trash system.tmp"
alias cv="cd ~/Desktop/cv"
alias pacman-installed-pkgs="LC_ALL=C pacman -Qi | awk '/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}' | sort -h"
alias cl="clear"
alias pgpt="cd ~/Desktop/projects/photoGPT/"
alias dbt="cd ~/Desktop/projects/dubit/"
alias oe="cd ~/Desktop/projects/odineye/"

if type -q eza
    alias ls="eza"
else
    echo "Install eza for nice ls experience."
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/manish/google-cloud-sdk/path.fish.inc' ]; . '/home/manish/google-cloud-sdk/path.fish.inc'; end
