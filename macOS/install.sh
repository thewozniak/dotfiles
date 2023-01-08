#!/bin/sh

bash ${HOME}/.dotfiles/nginxssl.sh

# Ask the user if they want to prepare the development environment
echo # just an empty line ;)
read -p "Do you want to prepare the development environment? [y/n] " answer

if [ "$answer" != "${answer#[Yy]}" ]; then

# Determine the machine hardware name
machine=$(uname -m)

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until code is finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Create an empty array named 'database' to add information about installed packages
database=()

# Check if Xcode is already installed
echo "\n[\033[1m\033[33mChecking up\033[0m\033[0m] Xcode command-line tools..."
if test ! $(which xcode-select); then
  # Xcode is not installed
  echo "\n[\033[1m\033[31mnot found\033[0m\033[0m] \033[1minstallation is recommended\033[0m"
  sleep 2
  # Install Xcode command-line tools
  echo "\033[1m\033[36m==>\033[0m\033[0m \033[1mlaunching:\033[0m \033[4m\033[3mxcode-select --install\033[0m\033[0m\n"
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

# Configure PHP environment
echo " " >> $php_ini
echo "[extension]" >> $php_ini
perl -i -pe 's/^(;\s*default_charset =|default_charset =).*/default_charset = "UTF-8"/' $php_ini
perl -i -pe 's/^(;\s*max_execution_time =|max_execution_time =).*/max_execution_time = 300/' $php_ini
perl -i -pe 's/^(;\s*max_file_uploads =|max_file_uploads =).*/max_file_uploads = 300/' $php_ini
perl -i -pe 's/^(;\s*max_input_nesting_level =|max_input_nesting_level =).*/max_input_nesting_level = 300/' $php_ini
perl -i -pe 's/^(;\s*max_input_time =|max_input_time =).*/max_input_time = 300/' $php_ini
perl -i -pe 's/^(;\s*max_input_vars =|max_input_vars =).*/max_input_vars = 1000/' $php_ini
perl -i -pe 's/^(;\s*memory_limit =|memory_limit =).*/memory_limit = 512M/' $php_ini
perl -i -pe 's/^(;\s*output_buffering =|output_buffering =).*/output_buffering = 4096/' $php_ini
perl -i -pe 's/^(;\s*post_max_size =|post_max_size =).*/post_max_size = 2048M/' $php_ini
perl -i -pe 's/^(;\s*precision =|precision =).*/precision = 14/' $php_ini
perl -i -pe 's/^(;\s*realpath_cache_size =|realpath_cache_size =).*/realpath_cache_size = 1M/' $php_ini
perl -i -pe 's/^(;\s*realpath_cache_ttl =|realpath_cache_ttl =).*/realpath_cache_ttl = 120/' $php_ini
perl -i -pe 's/^(;\s*serialize_precision =|serialize_precision =).*/serialize_precision = 17/' $php_ini
perl -i -pe 's/^(;\s*upload_max_filesize =|upload_max_filesize =).*/upload_max_filesize = 2048M/' $php_ini
perl -i -pe 's/^(;\s*user_ini.cache_ttl =|user_ini.cache_ttl =).*/user_ini.cache_ttl = 300/' $php_ini

# Change permissions for directories
sudo chmod -R 777 /private/tmp/pear/*
sudo chmod -R 777 /usr/local/share/pear/*

# Install PCRE (Perl Compatible Regular Expression)
brew install pcre

# Install Mongo PHP Driver for MongoDB using PECL
sudo pecl install mongodb

first_line=$(head -n 1 "$php_ini")
if [[ $first_line =~ "extension=\"mongodb.so\"" ]]; then
  sed -i -e "1d" "$php_ini"
  echo 'extension="mongodb.so"' >> $php_ini
fi
database+=("MongoDB PHP Driver (extension)")

# Install pkgconfig using Homebrew
brew instal pkg-config

# Install image processing tools collection
#brew install graphicsmagick

# Install imagick for PHP using PECL
yes '' | sudo pecl install imagick

# Install mailparse (email message manipulation) for PHP using PECL
sudo pecl install mailparse

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

# Download the nginx configuration template file
mv -f $nginx_file $nginx_file.conf.bak
curl https://woz.ooo/dl/dotfiles/macOS/nginx-template.conf -o $nginx_file

# Edit the Nginx configuration file and update the "user" and "root" directive
mkdir ${HOME}/Sites
sudo chmod -R 775 ${HOME}/Sites
perl -i -pe "s:{{user}}:${USER}:; s:{{root}}:${HOME}/Sites:" $nginx_file
#sed -i '' "s:{{user}}:${USER}:" $conf_file
#sed -i '' "s:{{root}}:${HOME}/Sites:" $conf_file

# Make directory for Error pages
mkdir ${HOME}/Sites/errors
sudo chmod -R 775 ${HOME}/Sites/errors

# Download the prepared static error pages
curl https://gist.githubusercontent.com/thewozniak/9ec84e272d553c94ac9f037334f36917/raw/712c8566cbf439e3ff2f7abe5177dcb013ed613f/page-401.html -o ${HOME}/Sites/errors/401.html
curl https://gist.githubusercontent.com/thewozniak/22978851c7313e947a8bc08f349a1b23/raw/cfa61c1ee20ae3c40b222f05032e2558f16838c8/page-403.html -o ${HOME}/Sites/errors/403.html
curl https://gist.githubusercontent.com/thewozniak/8f8ed28d7c787459b9a7883a7476f6ec/raw/e929ab553227d9a79b5949224808d3fccae786b8/page-404.html -o ${HOME}/Sites/errors/404.html
curl https://gist.githubusercontent.com/thewozniak/6e56d8fb60490cea2200bae803245325/raw/8a5bb66d7894fc480b1e6149a2b2e7d68f1c7c92/page-500.html -o ${HOME}/Sites/errors/500.html
curl https://gist.githubusercontent.com/thewozniak/7bdeb9a83cd7b9dc0e55393d11e4f0c3/raw/f600d5d3e7b0976fd2578389e99441710ce5b9ae/page-502.html -o ${HOME}/Sites/errors/502.html
curl https://gist.githubusercontent.com/thewozniak/8dc1c771d472598aceb2e92cfd380488/raw/289adc7ab163abf7eb510e720c1ff5f5fd30795e/page-503.html -o ${HOME}/Sites/errors/503.html
curl https://gist.githubusercontent.com/thewozniak/5c498f94b5b095585971f3580299ab4f/raw/626bdb67e41739a63cd85cea108601a19cf5d4dc/page-504.html -o ${HOME}/Sites/errors/504.html

# Make directory for SSL
# e.g: /usr/local/etc/nginx/ssl/ for Intel x86-64
# e.g: /opt/homebrew/etc/nginx/ssl/ for Apple M-series
mkdir $brew_path/etc/nginx/ssl/
sudo chown $(whoami):admin $brew_path/etc/nginx/ssl/
sudo chmod 755 $brew_path/etc/nginx/ssl/

# Add the line "127.0.0.1 dev.mac" to the end of the /etc/hosts file
echo "127.0.0.1       dev.mac" | sudo tee -a /etc/hosts

# Create the index.html file in the user's home directory
echo "<!DOCTYPE html><html><head><title>Welcome to nginx!</title><style>html { color-scheme: light dark; } body { width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; } p.dev{ margin-left:18px; }</style></head><body><h1>Welcome to nginx!</h1><p>If you see this page, the nginx web server is successfully installed and working. Further configuration is required.</p><p>For online documentation and support please refer to <a href='http://nginx.org/'>nginx.org</a>.<br/>Commercial support is available at <a href='http://nginx.com/'>nginx.com</a>.</p><p class='dev'>The addresses of the development environment are:<br /><strong><em>http(s)://localhost</strong> and <strong>http(s)://dev.mac</em></strong><br />and both are running on ports 80, 443</p><p class='dev'>The directory with the files for the home page is: ${HOME}/Sites<br/>Click <a href='php-info.php'>here</a> to view phpinfo() configuration.</p><p><em>Thank you for using nginx</em></p><p><em>&copy; 2022 - <a href='https://woz.ooo'>woz.ooo</a></em></p></body></html>" > ${HOME}/Sites/index.html
sudo chmod -R 644 ${HOME}/Sites/index.html

# Create the PHP Info file in the user's home directory
echo "<?php echo phpinfo(); ?>" > ${HOME}/Sites/php-info.php
sudo chmod -R 644 ${HOME}/Sites/php-info.php

# Change the group for the directory and files
chgrp -R -f staff ${HOME}/Sites

# Download the .zshrc file to your home directory
rm -rf ${HOME}/.zshrc
curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/.zshrc -o ~/.zshrc

# Create and add SSL certificates for hosts
source ${HOME}/.dotfiles/nginxssl.sh
nginxssl localhost
nginxssl dev.mac

# Reload nginx service as a root
sudo nginx -s reload
database+=("Nginx Web Server")

echo # another empty line ;)
read -p "Do you want to install essential apps? [y/n] " answer
if [ "$answer" != "${answer#[Yy]}" ]; then
 # Install Mac App Store command-line interface
 brew install mas
 # Install Karabiner-elements
 brew install --cask karabiner-elements
  # Install NoSQLBooster for MongoDB
 brew install --cask nosqlbooster-for-mongodb
 # Install Realm Studio
 brew install --cask mongodb-realm-studio
 # Install AppCleaner
 brew install --cask appcleaner
 echo # another empty line ;)
 read -p "Do you want to install VS Code? [y/n] " vscode
 if [ "$vscode" != "${vscode#[Yy]}" ]; then
 # Install VS Code
 brew install --cask visual-studio-code
 fi
 echo # another empty line ;)
 read -p "Do you want to install DevUtils? [y/n] " devutils
 if [ "$devutils" != "${devutils#[Yy]}" ]; then
 # Install DevUtils
 brew install --cask devutils
 fi
 echo # another empty line ;)
 read -p "Do you want to install Screens? [y/n] " screens
 if [ "$screens" != "${screens#[Yy]}" ]; then
 # Install Screens 4
 brew install --cask screens
 fi
 echo # another empty line ;)
 read -p "Do you want to install Panic Nova? [y/n] " nova
 if [ "$nova" != "${nova#[Yy]}" ]; then
 # Install Panic Nova
 brew install --cask nova
 fi
 echo # another empty line ;)
 read -p "Do you want to install Little Snitch? [y/n] " snitch
 if [ "$snitch" != "${snitch#[Yy]}" ]; then
 # Install Little Snitch
 brew install --cask little-snitch
 fi
 echo # another empty line ;)
 read -p "Do you want to install UTM (QEMU Virtual Machines UI)? [y/n] " utm
 if [ "$utm" != "${utm#[Yy]}" ]; then
 # Install UTM (Virtual machines UI using QEMU)
 brew install --cask utm
 fi
 echo # another empty line ;)
 read -p "Do you want to install Sensei.app? [y/n] " sensei
 if [ "$sensei" != "${sensei#[Yy]}" ]; then
 # Install Sensei
 brew install --cask sensei
 fi
 echo # another empty line ;)
 read -p "Do you want to install Publii? [y/n] " publii
 if [ "$publii" != "${publii#[Yy]}" ]; then
 brew install --cask publii
 fi
 echo # another empty line ;)
 read -p "Do you want to install The Unarchiver? [y/n] " unarch
 if [ "$unarch" != "${unarch#[Yy]}" ]; then
 mas install 425424353
 fi
 echo # another empty line ;)
 read -p "Do you want to install Twitter? [y/n] " twitter
 if [ "$twitter" != "${twitter#[Yy]}" ]; then
 mas install 1482454543
 fi
 echo # another empty line ;)
 read -p "Do you want to install Commander One Pro? [y/n] " commander
 if [ "$commander" != "${commander#[Yy]}" ]; then
 mas install 1035237815
 fi
 echo # another empty line ;)
 read -p "Do you want to install HTTPBot? [y/n] " httpbot
 if [ "$httpbot" != "${httpbot#[Yy]}" ]; then
 mas install 1232603544
 fi
 echo # another empty line ;)
 read -p "Do you want to install Spark Mail? [y/n] " spark
 if [ "$spark" != "${spark#[Yy]}" ]; then
 mas install 1176895641
 fi
 echo # another empty line ;)
 read -p "Do you want to install 1Blocker? [y/n] " oneblock
 if [ "$oneblock" != "${oneblock#[Yy]}" ]; then
 mas install 1365531024
 fi
 echo # another empty line ;)
 read -p "Do you want to install HEIC Converter? [y/n] " heic
 if [ "$heic" != "${heic#[Yy]}" ]; then
 mas install 1294126402
 fi
fi

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

echo # empty line ;)
echo "\033[1mThe following packages and libraries have been installed:\033[0m"
for item in "${database[@]}"
do
echo "- $item"
done

echo "\n\033[32mDONE!\033[0m \033[1mDevelopment Enviroment\033[0m is ready to code!"
echo "\n\033[1mPHP\033[0m is running on port: \033[4m9000\033[0m (user: ${USER})"
echo "\033[1mNginx\033[0m is running on ports: \033[4m80\033[0m, \033[4m443\033[0m (user: root)"
echo "\nYour dev-env address is: \033[1m\033[4m\033[3mhttp(s)://dev.mac\033[0m\033[0m\033[0m and \033[1m\033[4m\033[3mhttp(s)://localhost\033[0m\033[0m\033[0m"
echo "Sites default files path is: \033[4m\033[3m${HOME}/Sites\033[0m\033[0m"
echo "\nPHP configuration file path is: \033[4m\033[3m$php_ini\033[0m\033[0m"
echo "Nginx configuration file path is: \033[4m\033[3m$nginx_file\033[0m\033[0m"
echo "\nBy default \033[1mPHP\033[0m and \033[1mNginx\033[0m are up and \033[1m\033[32mrunning.\033[01m\033[0m\nType in: \033[4mdev stop\033[0m to halt services"
echo "\nFor mor information check \033[1mdev-env.md\033[0m file in your homedir: \033[4m\033[3m~/dev-env.md\033[0m\\033[0m\n"

echo "
# ~/dotfiles macOS develompent enviroment
# GitHub: https://github.com/thewozniak
# WebSite: https://woz.ooo

PHP is running on port: 9000 (user: ${USER})
Nginx is running on ports: 80, 443 (user: root)

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
