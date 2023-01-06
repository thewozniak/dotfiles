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
    if [ "$1" == "install" ]; then
      text="Preparing dev-env..."
      tput setaf 0 
      tput bold
      for (( i=0; i<10; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.05
      done
      tput sgr0
      tput setaf 6 
      tput bold
      for (( i=10; i<17; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.05
      done
      tput sgr0
      for (( i=17; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.05
      done     
    else
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
    fi
    # Removes .zshrc from $HOME (if it exists)
    # rm -rf $HOME/.zshrc
    # Make directory /.dotfiles
    mkdir ${HOME}/.dotfiles
    chmod 755 ${HOME}/.dotfiles
    if [ "$1" == "install" ]; then
    echo # empty line ;)
    # Download the script using curl
    curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/install.sh > ${HOME}/.dotfiles/install.sh
    # Make the scripts executable
    chmod +x ${HOME}/.dotfiles/install.sh
    # Run the script
    ${HOME}/.dotfiles/install.sh
    else
    # Download the scripts using curl
    curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/set-defaults.sh > ${HOME}/.dotfiles/set-defaults.sh
    curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/install.sh > ${HOME}/.dotfiles/install.sh
    # Make the scripts executable
    chmod +x ${HOME}/.dotfiles/set-defaults.sh
    chmod +x ${HOME}/.dotfiles/install.sh
    # Run the scripts one after the other
    ${HOME}/.dotfiles/set-defaults.sh
    ${HOME}/.dotfiles/install.sh       
    fi
    # Delete the /.dotfiles directory and all of its contents
    rm -r ${HOME}/.dotfiles
    echo # empty line
    echo -e "\n\033[32mDONE!\033[0m You're ready to fly! ;)"
    rm -f remote.sh
    read -p "Do you want to restart the system? (y/n) " -n 1 choice
    echo # empty
    if [[ $choice == "y" ]]; then
      echo "Restarting system in 3 seconds..."
      sleep 3
      sudo shutdown -r now
    else
      echo "OK, restart cancelled"
    fi
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

