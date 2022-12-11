# 

## dotfiles

These are my personal dofilest. If you'd like to learn more about it, check out [GitHub ❤ ~/](http://dotfiles.github.io) page.

In addition to configuring macOS to the default settings I use, the following components and libraries will be installed:
- Xcode command-line tools
- Homebrew
- Nginx
- PHP
- Composer
- Node
- Pecl
- MongoDB

During the installation process, there is a possibility to enter additional packages to be installed - only if they are available in homebrew repository.

## Install

Run this:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thewozniak/dotfiles/main/remote.sh)"
```

This will download and run the appropriate files into in `.dotfiles` to your $HOME directory.
After the process is done, use the command: `rm -f remote.sh` to clean up.
