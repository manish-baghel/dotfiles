# My Dotfiles

## Vim

Put below content in `~/.vimrc`

Note: There are some Compatibility issues with vim, but works fine with neovim 

```vim
source ~/dotfiles/vim/ultimate_rc.vim
lua require('plugins_config')
source ~/dotfiles/vim/plugins_config.vim
```
And follow below steps to transfer the necessary file to `.config/nvim/lua` directory
```bash
mkdir -p ~/.config/nvim/lua
cp ~/dotfiles/vim/plugins_config.lua ~/.config/nvim/lua/
```

## ZSH

Put below content in `~/.zshrc` or `~/.zprofile`

```
source Path/to/dotfiles/zsh/themes/powerlevel9k/powerlevel9k.zsh-theme
```

## Random Stuff

### Git Config for diff

```bash
git config --global diff.tool vimdiff
git config --global difftool.vimdiff.path nvim #if using neovim 
git config --global alias.d difftool
git config --global difftool.prompt false
```
