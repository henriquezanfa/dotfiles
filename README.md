```
git clone git@github.com:henriquezanfa/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` symlinks nvim, tmux, workmux, sesh, tuicr and tt into place (existing files are backed up as `*.bak.<timestamp>`), installs sesh via brew, and builds tt with cargo. tuicr must be installed manually.
