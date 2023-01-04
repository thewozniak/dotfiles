# 

## dotfiles

These are my personal dofilest. If you'd like to learn more about it, check out [GitHub ❤ ~/](http://dotfiles.github.io) page.

It helps me and speeds up system configurations, to my preferred settings. In addition to configuring macOS to the defaults I use, you can install the following development environment components and libraries:
+ <strong>Mac App Store command-line interface</strong>
+ <strong>Xcode command-line tools</strong>
+ <strong>Homebrew</strong>
+ <strong>OpenSSL</strong>
+ <strong>Wget</strong>
+ <strong>PHP (8.x)</strong>
+ <strong>Nginx (1.2x.x)</strong>
+ <strong>Composer</strong>
+ <strong>Node</strong>
- MongoDB PHP Driver
- OAuth consumer extension
- Redis PHP extension
- mailparse PHP extension
- msgpack PHP extension
- imagick (ImageMagick)
- pkg-config (helper tool)
+ Karabiner-elements
+ Visual Studio Code (VSCode)
+ NoSQLBooster for MongoDB
+ Realm Studio



During the installation process, you can install additional libraries available in the homebrew repository.
<br /><br />

## Install

Run this:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thewozniak/dotfiles/main/remote.sh)"
```

This will download and run the appropriate files in `.dotfiles` to your $HOME directory.

Don't worry! Once the process is complete, all files will be cleaned up.

After the installation is complete, <strong>PHP</strong> and <strong>Nginx</strong> are running because they were started during the installation process.

To display the status of running services, type: `dev status`.

If you nedd to stop dev-env, type as following: `dev stop`.
<br /><br />

## Usage


### Basics dev-env commands<br />

`dev start` - to start dev-env

`dev stop` - to stop dev-env

`dev restart` - to restart dev-env

`dev status` - to check status of services

<br />

### Commands for database services<br />

`dev db` - to check if aby database services are running or not

`dev mongo` - to get information how to install the latest MongoDB-Community

`dev redis start|stop|restart` - to start|stop|restart Redis

`dev mongo start|stop|restart` - to start|stop|restart MongoDB-Community

`dev mysql start|stop|restart` - to start|stop|restart MySQL

`dev postgresql start|stop|restart` - to start|stop|restart PostgreSQL

<strong>Note that each database must first be installed on the system.</strong>

You can use the `dev db install` command to install all the most popular databases, ie: Redis, MongoDB, MySQL and PostgreSQL

<br />

### Additional available commands<br />

`getpasswd` - generates a random password with a length of 24 characters

`killport (number)` - to kill processes running on a specific port (e.g.: killport 8080)

`nginxssl (host)` - to create new host with SSL (e.g.: nginxssl web.x)


<br />

### Enviroment details<br />

<strong>PHP</strong> is running on port: <strong>9000</strong> (user: $user)<br />
<strong>Nginx</strong> is running on ports: <strong>80, 443</strong> (user: root)<br />

Your dev-env address is: <i>http(s)://dev.mac</i> and <i>http(s)://localhost</i><br />
Sites default files path is: <i>$HOME/Sites</i> (<i>/Users/<user_name>/Sites</i>)<br />


```sh
# Paths to configuration files for Intel x86 Chipsets:

PHP (php.ini)           /usr/local/etc/php/8.x/php.ini
Nginx (nginx.conf)      /usr/local/etc/nginx/nginx.conf
```



```sh
# Paths to configuration files for Apple Silicons (SoC):

PHP (php.ini)           /opt/homebrew/etc/php/8.x/php.ini
Nginx (nginx.conf)      /opt/homebrew/etc/nginx/nginx.conf
```



```sh
# Paths to nginx servers configuration files is:

Intel x86 Chipsets       /usr/local/etc/nginx/servers/
Apple Silicons (SoC)     /opt/homebrew/etc/nginx/servers/
```


```sh
# Paths to SSL (.crt/.key) files is:

Intel x86 Chipsets       /usr/local/etc/nginx/ssl/
Apple Silicons (SoC)     /opt/homebrew/etc/nginx/ssl/
```

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/E1E3HJ8PE)
