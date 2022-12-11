#!/usr/bin/env bash

# Get the name of the unix
WHAT_ENV=$(uname)

# Check the operating system and set the environment name
case "$WHAT_ENV" in
  "Darwin")
    # Check the architecture and set the environment name
    case "$(uname -m)" in
      "x86_64")
        WHAT_ENV="IntelMac"
        ;;
      "arm")
        WHAT_ENV="AppleSilicon"
        ;;
      *)
        WHAT_ENV="Unknown"
        ;;
    esac
    ;;
  "Linux")
    WHAT_ENV="Linux"
    ;;
  *)
    WHAT_ENV="Unknown"
    ;;
esac

# Use the appropriate dotfiles for the environment
case "$WHAT_ENV" in
  "IntelMac"|"AppleSilicon")

    echo "Setting up your Mac..."

    # Removes .zshrc from $HOME (if it exists)
    rm -rf $HOME/.zshrc
    # Make directory /.dotfiles
    mkdir ${HOME}/.dotfiles
    # Download and run the files
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/set-defaults.sh -o ${HOME}/.dotfiles/set-defaults.sh)" &&
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/install.sh -o ${HOME}/.dotfiles/install.sh)" &&
    # Delete the /.dotfiles directory and all of its contents
    rm -r ${HOME}/.dotfiles

    echo "Done. You're ready to fly! ;)"

    ;;
  "Linux")
    # dotfiles for Linux Ubuntu
    # will be added in the future
    ;;
  *)
    echo "Unknown environment... Aborting.."
    ;;
esac

