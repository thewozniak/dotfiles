#!/bin/sh

# Ask the user if they want to prepare the development environment
echo # just an empty line ;)
read -p -e "\033[1mDo you want to prepare the development environment?\033[0m [y/n] " answer

if [ "$answer" != "${answer#[Yy]}" ]; then

# Determine the machine hardware name
machine=$(uname -m)

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until code is finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Clear terminal and display information
clear
echo -e "\n\n"
text="Starting to set up a Development Environment..."
tput setaf 0 
tput bold
for (( i=0; i<21; i++ )); do
  echo -n "${text:$i:1}"
  sleep 0.05
done
tput sgr0
tput setaf 4 
tput bold
for (( i=21; i<43; i++ )); do
  echo -n "${text:$i:1}"
  sleep 0.05
done
tput sgr0
for (( i=44; i<${#text}; i++ )); do
  echo -n "${text:$i:1}"
  sleep 0.05
done
echo -e "\n\n\n"
sleep 3

# Create an empty array named 'database' to add information about installed packages
database=()

# Check if Xcode is already installed
echo -e "\n[\033[1m\033[33mChecking up\033[0m\033[0m] Xcode command-line tools..."
if test ! $(which xcode-select); then
  # Xcode is not installed
  echo -e "\n[\033[1m\033[31mnot found\033[0m\033[0m] \033[1minstallation is recommended\033[0m"
  sleep 2
  # Install Xcode command-line tools
  echo -e "\033[1m\033[36m==>\033[0m\033[0m \033[1mlaunching:\033[0m \033[4m\033[3mxcode-select --install\033[0m\033[0m\n"
  sleep 2  
  xcode-select --install
  # Add installed package to the array
  database+=("Xcode command-line tools")
else
  # Xcode is already installed
  # No action needed
  echo "\033[1m\033[36m==>\033[0m\033[0m Xcode is \033[4malready installed\033[0m. \033[1mSkipping...\033[0m"
fi

# Install Homebrew if it is not already installed
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew update
  # Add installed package to the array
  database+=("Homebrew")
else
  brew update
  brew_version=$(brew --version)
  echo "The currently installed version of Homebrew is $brew_version"  
fi

# Check if the machine hardware name is "x86_64" or "arm64"
if [ "$machine" = "x86_64" ]; then
  # The machine hardware is "x86_64"
  # Use the path for the Nginx configuration file on x86-64 Macs
  nginx_file="/usr/local/etc/nginx/nginx.conf"
  brew_path="/usr/local"
elif [ "$machine" = "arm64" ]; then
  # The machine hardware is "arm64"
  # Use the path for the Nginx configuration file on Apple Silicon Macs
  nginx_file="/opt/homebrew/etc/nginx/nginx.conf"
  brew_path="/opt/homebrew"
else
  # The machine hardware is unknown
  # Print an error message and exit the script
  echo "Error: Unknown machine hardware."
  exit 1
fi

# Install OpenSSL using Homebrew
brew list openssl || brew install openssl
database+=("OpenSSL")

# Install Wget using Homebrew
brew list wget || brew install wget
database+=("Wget")

# Install PHP using Homebrew
brew list php || brew install php
database+=("PHP")

# Start PHP using Homebrew
brew services start php

# Install composer using Homebrew
brew list composer || brew install composer
# Add installed package to the array
database+=("Composer")

# Install NodeJS (npm) using Homebrew
brew list node || brew install node
# Add installed package to the array
database+=("NodeJS (npm)")

# Determine the location of the php.ini file
php_ini=$(php -r "phpinfo();" | grep php.ini | cut -d' ' -f5)
# Output e.g:
# /usr/local/etc/php/7.4/php.ini

# Check if the php.ini file exists in the default location
if test -f $php_ini; then
  # The php.ini file exists in the default location
else
  # The php.ini file does not exist in the default location
fi

# Change permissions for directories
sudo chmod -R 777 /private/tmp/pear/*
sudo chmod -R 777 /usr/local/share/pear/*

# Install PCRE (Perl Compatible Regular Expression)
brew install pcre

# Install Mongo PHP Driver for MongoDB using PECL
sudo pecl install mongodb

if grep -q "^extension=mongodb.so" $php_ini; then
  sed -i '/^extension=mongodb.so/d' $php_ini
fi
if grep -q "\[extensions\]" $php_ini; then
  if grep -q "mongodb.so" $php_ini; then
    sed -i '/^extension=mongodb.so/d' $php_ini
  fi
else
  echo "[extensions]" | sudo tee -a $php_ini
fi
echo "extension=mongodb.so" | sudo tee -a $php_ini
database+=("MongoDB PHP Driver (extension)")

# Install pkgconfig using Homebrew
brew instal pkg-config

# Install image processing tools collection
brew install GraphicsMagick

# Install imagick for PHP using PECL
yes '' | sudo pecl install imagick

# Install mailparse (email message manipulation) for PHP using PECL
sudo pecl install mailparse

# Install msgpack using Homebrew
brew install msgpack
if grep -q "^extension=msgpack.so" $php_ini; then
  sed -i '/^extension=msgpack.so/d' $php_ini
fi
echo "extension=msgpack.so" | sudo tee -a $php_ini

# Install OAuth using PECL insted of Homebrew
pecl install oauth

# Install Redis using PECL
yes '' | sudo pecl install redis

# Install nginx using Homebrew
brew list nginx || brew install nginx

# Kill all processes that use port 80
lsof -i -P | grep -i "80" | awk "{print $2}" | xargs kill

# Start nginx as a root (necessary to run the service on port 80)
sudo nginx

# Download pre-configured nginx.conf file
# default path for Intel x86-64 Chipset into nginx.conf file is: /usr/local/etc/nginx/nginx.conf
# default path for Apple Silicon M-Series Chipset into nginx.conf file is: /opt/homebrew/etc/nginx/nginx.conf

mv -f $nginx_file $nginx_file.bak
curl https://woz.ooo/dl/dotfiles/macOS/nginx.conf -o $nginx_file

# Make directory for SSL
# e.g: /usr/local/etc/nginx/ssl/ for Intel x86-64
# e.g: /opt/homebrew/etc/nginx/ssl/ for Apple M-series
mkdir $brew_path/etc/nginx/ssl/

# Add the line "127.0.0.1 dev.mac" to the end of the /etc/hosts file
echo "127.0.0.1       dev.mac" | sudo tee -a /etc/hosts

# Edit the Nginx configuration file and update the "root" directive
mkdir ${HOME}/Sites
sudo chmod -R 775 ${HOME}/Sites
sed -i '' '1 s/^#*user[[:blank:]]\+.*;/user  ${USER} staff;/' $conf_file
sed -i '' 's#^\( *\)root /.*;#\1root ${HOME}/Sites;#' $conf_file

# Create the index.html file in the user's home directory
echo "<!DOCTYPE html><html><head><title>Welcome to nginx!</title><style>html { color-scheme: light dark; } body { width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; } p.dev{ margin-left:18px; }</style></head><body><h1>Welcome to nginx!</h1><p>If you see this page, the nginx web server is successfully installed and working. Further configuration is required.</p><p>For online documentation and support please refer to <a href='http://nginx.org/'>nginx.org</a>.<br/>Commercial support is available at <a href='http://nginx.com/'>nginx.com</a>.</p><p class='dev'>The addresses of the development environment are:<br /><strong><em>http://localhost</strong> and <strong>http://dev.mac</em></strong><br />and both are running on port 80</p><p class='dev'>The directory with the files for the home page is: ${HOME}/Sites<br/>Click <a href='php-info.php'>here</a> to view phpinfo() configuration.</p><p><em>Thank you for using nginx</em></p><p><em>&copy; 2022 - <a href='https://woz.ooo'>woz.ooo</a></em></p></body></html>" > ${HOME}/Sites/index.html
sudo chmod -R 644 ${HOME}/Sites/index.html

# Create the PHP Info file in the user's home directory
echo "<?php echo phpinfo(); ?>" > ${HOME}/Sites/php-info.php
sudo chmod -R 644 ${HOME}/Sites/php-info.php

# Change the group for the directory and files
chgrp -R -f staff ${HOME}/Sites

# Reload nginx service as a root
sudo nginx -s reload
database+=("Nginx Web Server")

# Install Karabiner-elements
#brew install --cask karabiner-elements
curl https://woz.ooo/dl/dotfiles/macOS/karabiner.json -o /Users/${USER}/.config/karabiner/karabiner.json

# Initialize a variable to control the loop
install_more_packages=true


# Start the loop
while [ $install_more_packages == true ]
do
  # Ask the user if they want to install additional packages
  echo # another empty line ;)
  read -p "Do you want to install any additional packages from the Homebrew repository? [y/n] " answer

  if [ "$answer" != "${answer#[Yy]}" ]; then
    # Ask the user for the name of the package they want to install
    echo # and another one ;))
    read -p "Enter the name of the package you want to install: " package

    # Check if the package is present in the Homebrew repository
    brew search $package

    # If the package is not present, display an error message
    if [ $? -ne 0 ]; then
      echo "Error: Package $package is not present in the Homebrew repository."
    else
      if [ $package == "mongodb" ] || [ $package == "mongo" ]; then
        # Install MongoDB using the mongodb/brew tap
        brew tap mongodb/brew
        brew list mongodb-community || brew install mongodb-community
        # Add installed package to the array
        database+=("MongoDB")
        # Install NoSQLBooster for MongoDB using Homebrew Cask
        brew list --cask nosqlbooster-for-mongodb || brew install --cask nosqlbooster-for-mongodb
      else
      # The package is present in the repository
      # Install the package using Homebrew
      brew list $package || brew install $package
      # Add installed package to the array
      # database+=("$package")
      fi
    fi
  else
    # The user does not want to install additional packages
    # Set the loop control variable to false to exit the loop
    install_more_packages=false
  fi
done

# Download the .zshrc file to your home directory
rm -rf ${HOME}/.zshrc
curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/.zshrc -o ~/.zshrc

echo -e "\033[1mThe following packages and libraries have been installed:\033[0m"
for item in "${database[@]}"
do
echo -e "- $item"
done

echo -e "\n\033[32mDONE!\033[0m \033[1mDevelopment Enviroment\033[0m is ready to code!"
echo -e "\n\033[1mPHP\033[0m is running on port: \033[4m9000\033[0m (user: ${USER})"
echo -e "\033[1mNginx\033[0m is running on port: \033[4m80\033[0m (user: root)"
echo -e "\nYour dev-env address is: \033[1m\033[4m\033[3mhttp://dev.mac\033[0m\033[0m\033[0m and \033[1m\033[4m\033[3mhttp://localhost\033[0m\033[0m\033[0m"
echo -e "Sites default files path is: \033[4m\033[3m${HOME}/Sites\033[0m\033[0m"
echo -e "\nPHP configuration file path is: \033[4m\033[3m$php_ini\033[0m\033[0m"
echo -e "Nginx configuration file path is: \033[4m\033[3m$nginx_file\033[0m\033[0m"
echo -e "\nBy default \033[1mPHP\033[0m and \033[1mNginx\033[0m are up and \033[1m\033[32mrunning.\033[01m\033[0m\nType in: \033[4mdev stop\033[0m to halt services"
echo -e "\nFor mor information check \033[1mdev-env.md\033[0m file in your homedir: \033[4m\033[3m~/dev-env.md\033[0m\\033[0m\n"

echo "
# ~/dotfiles macOS develompent enviroment
# GitHub: https://github.com/thewozniak
# WebSite: https://woz.ooo

PHP is running on port: 9000 (user: ${USER})
Nginx is running on port: 80 (user: root)

Your dev-env address is: http://dev.mac and http://localhost
Sites default files path is: ${HOME}/Sites

PHP configuration file path is: $php_ini
Nginx configuration file path is: $nginx_file

# Basics dev-env commands are:
dev start - to start dev-env
dev stop - to stop dev-env
dev restart - to restart dev-env
dev status - to check status of services

# Commands for database services:
dev db - to check if aby database services are running or not
dev mongo - to get information how to install the latest MongoDB-Community
dev redis start|stop|restart - to start|stop|restart Redis service (must be installed first in the system)
dev mongo start|stop|restart - to start|stop|restart MongoDB-Community service (must be installed first in the system)
dev mysql start|stop|restart - to start|stop|restart MySQL service (must be installed first in the system)
dev postgresql start|stop|restart - to start|stop|restart PostgreSQL service (must be installed first in the system)

# Additional commands available:
getpasswd - generates a random password with a length of 24 characters
killport - to kill processes running on a specific port (e.g.: killport 8080)
" > ${HOME}/dev-env.md

else
  # The user does not want to prepare the development environment
  # Halt the script
  exit 0
fi
