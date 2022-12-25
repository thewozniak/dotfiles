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
    echo -e "\n"
    text="Preparing a Mac..."
    tput setaf 0 
    tput bold
    for (( i=0; i<12; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.05
    done
    tput sgr0
    tput setaf 6 
    tput bold
    for (( i=12; i<15; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.05
    done
    tput sgr0
    for (( i=15; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.05
    done
    echo -e "\r\n"
    # Removes .zshrc from $HOME (if it exists)
    # rm -rf $HOME/.zshrc
    # Make directory /.dotfiles
    mkdir ${HOME}/.dotfiles
    chmod 755 ${HOME}/.dotfiles
    # Download and run the files
    # Download the scripts using curl
    curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/set-defaults.sh > ${HOME}/.dotfiles/set-defaults.sh
    curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/install.sh > ${HOME}/.dotfiles/install.sh
    # Make the scripts executable
    chmod +x ${HOME}/.dotfiles/set-defaults.sh
    chmod +x ${HOME}/.dotfiles/install.sh
    # Run the scripts one after the other
    ${HOME}/.dotfiles/set-defaults.sh
    ${HOME}/.dotfiles/install.sh    
    # Delete the /.dotfiles directory and all of its contents
    rm -r ${HOME}/.dotfiles
    echo # empty line
    echo -e "\n\033[32mDONE!\033[0m You're ready to fly! ;)"
    ;;
  "Linux")
    # dotfiles for Linux Ubuntu
    # will be added in the future
    ;;
  *)
    echo # empty line
    echo "Unknown environment... Aborting.."
    ;;
esac

