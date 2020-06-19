# My Dotfiles

## Vim

Put below content in `~/.vimrc`

Note: There are some Compatibility issues with vim, but works fine with neovim 

```vim
source Path/to/dotfiles/vim/ultimate_rc.vim
source Path/to/dotfiles/vim/plugins_config.vim
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
