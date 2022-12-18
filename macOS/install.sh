#!/bin/sh

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
if xcode-select -p -q > /dev/null; then
  # Xcode is already installed
  # No action needed
  echo "Xcode is already installed. Skipping..."
else
  # Xcode is not installed
  # Install Xcode command-line tools
  xcode-select --install
  # Add installed package to the array
  database+=("Xcode command-line tools")
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

# Install nginx using Homebrew
brew list nginx || brew install nginx

# Install PHP using Homebrew
brew list php || brew install php

# Check if the machine hardware name is "x86_64" or "arm64"
if [ "$machine" = "x86_64" ]; then
  # The machine hardware is "x86_64"
  # Use the path for the Nginx configuration file on x86-64 Macs
  conf_file="/usr/local/etc/nginx/nginx.conf"
  brew_path="/usr/local"
elif [ "$machine" = "arm64" ]; then
  # The machine hardware is "arm64"
  # Use the path for the Nginx configuration file on Apple Silicon Macs
  conf_file="/opt/homebrew/etc/nginx/nginx.conf"
  brew_path="/opt/homebrew"
else
  # The machine hardware is unknown
  # Print an error message and exit the script
  echo "Error: Unknown machine hardware."
  exit 1
fi

# Edit the Nginx configuration file and update the "root" directive
mkdir ${HOME}/Sites
sed -i '' 's#^\( *\)root /.*;#\1root ${HOME}/Sites;#' $conf_file

# Create the index.html file in the user's home directory
echo "<strong>Welcome to nginx!</strong><br><br>
If you see this page, the nginx web server is successfully installed and working.<br>
Further configuration may be needed.<br><br>
Path to the home page web files is: ${HOME}
You can view the PHP configuration <a href="php_info.php">here</a>" > ${HOME}/Sites/index.html
# Create the PHP Info file in the user's home directory
echo "<?php phpinfo(); ?>" > ${HOME}/Sites/php_info.php

# Add installed package to the array
database+=("Nginx Web Server")
database+=("PHP")

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
  # Check if the mongodb extension is already added to the php.ini file
  if ! grep -q "mongodb" $php_ini; then
    # Add the mongodb extension to the end of the php.ini file
    echo "
    [mongodb]
    extension=\"mongodb.so\"" >> $php_ini
    database+=("MongoDB PHP Driver (extension)")
  else
    # The mongodb extension is already added to the php.ini file
    echo "MongoDB extension is already added to PHP configuration!"
  fi

else

  # The php.ini file does not exist in the default location
  # Check if the file exists in the alternate location
  if test -f /etc/php.ini.default; then

    # The php.ini file exists in the alternate location
    # Copy the file to the default location
    cp /etc/php.ini.default $php_ini

    # Edit the file and add the line "extension=mongodb.so" at the end of the file
    echo "
    [mongodb]
    extension=\"mongodb.so\"" >> $php_ini
    # Add installed package to the array
    database+=("MongoDB PHP Driver (extension)")

  else

    # The php.ini file does not exist
    # Display an error message
    echo "Error: The file $brew_path/etc/php/$php_version/php.ini does not exist."

    # Create php.ini file
    touch $brew_path/etc/php/$php_version/php.ini

    # Edit the file and add the line "extension=mongodb.so"
    #echo "
    #[mongodb]
    #extension=\"mongodb.so\"" >> $php_ini
    # Add installed package to the array
    #database+=("MongoDB PHP Driver (extension)")

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
      if [ $package == "mongodb" ]; then
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
      #database+=("$package")
      fi
    fi
  else
    # The user does not want to install additional packages
    # Set the loop control variable to false to exit the loop
    install_more_packages=false
  fi
done

# Download the .zshrc file to your home directory
curl https://raw.githubusercontent.com/thewozniak/dotfiles/main/macOS/.zshrc -o ~/.zshrc

echo "The following packages and libraries have been installed:"
for item in "${database[@]}"
do
echo -e "- $item"
done

else
  # The user does not want to prepare the development environment
  # Halt the script
  exit 0
fi
