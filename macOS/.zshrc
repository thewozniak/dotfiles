# Reload bash stuff
alias reload='. ~/.zshrc'

# Generate a random password of 24 characters
alias getpasswd='echo `env LC_CTYPE=C tr -dc "A-Za-z0-9.$&^@!;" < /dev/urandom | head -c 24`'

function killport() {
  if [ -z "$1" ]; then
    echo # empty line ;)
    echo "\033[1m!!!\033[0m Expected parameter (port number)"
    echo "e.g.: \033[4m\033[3mkillport 80\033[0m\033[0m, \033[4m\033[3mkillport 443\033[0m\033[0m"
    echo # empty line ;)
  elif [[ "$1" =~ ^[0-9]{2,5}$ ]]; then
    # Ask for the administrator password upfront
    sudo -v
    lsof -i -P | grep -i "$1" | awk "{print $2}" | xargs kill
    fi
  else
    echo # empty line ;)
    echo "\033[1m[ERROR]\033[0m Expected parameter (port number)"
    echo "Expected parameter must contain 2 to 5 digits (e.g.: \033[4m\033[3mkillport 443\033[0m\033[0m)"
    echo # empty line ;)
  fi
}

function dev() {
# Ask for the administrator password upfront
sudo -v
  if [ -z "$1" ] || [ "$1" = "info" ] ; then
    dev status
    echo "----"
    echo # empty line ;)
    echo "To \033[1mstart\033[0m, \033[1mstop\033[0m or \033[1mrestart\033[0m development enviroment (\033[1mNginx\033[0m with \033[1mPHP\033[0m)"
    echo "type the following command: \033[3m\033[4mdev start\033[0m\033[0m or \033[3m\033[4mdev stop\033[0m\033[0m or \033[3m\033[4mdev restart\033[0m\033[0m"
    echo # empty line ;)
    echo "\033[1mUsage for additional services:\033[0m \033[3mdev start\033[0m|\033[3mstop\033[0m|\033[3mrestart\033[0m [\033[3mservice\033[0m]"
    echo "e.g.: \033[3m\033[4mdev start mongodb-community\033[0m\033[0m"
    echo # empty line ;)
    echo "If you have installed additional databases such as MySQL, PostgreSQL"
    echo "MongoDB or Redis, you can start/stop all of them with the command:"
    echo "\033[3m\033[4mdev db start\033[0m\033[0m, \033[3m\033[4mdev db stop\033[0m\033[0m or \033[3m\033[4mdev db restart\033[0m\033[0m"
    echo # empty line ;)
    echo "To check what databases you have installed, type in: \033[3m\033[4mdev db\033[0m\033[0m"  
    echo # empty line ;) 
    echo "To check what services are running or not, type in: \033[3m\033[4mdev status\033[0m\033[0m"  
    echo # empty line ;)       
  else

    if [ "$1" = "status" ]; then
    # Define array of services
    services=("php" "nginx" "mongodb-community" "mysql" "postgresql" "redis")
    # Loop through list of services and sheck status of each 
    echo # empty line ;)
    for service in "${services[@]}"; do
      # Check if service is installed
      check_exists=$(brew list | grep "$service")
      # Use awk to modify service name
      servicename=$(echo "$service" | awk '{gsub(/php/, "PHP", $1); gsub(/nginx/, "Nginx", $1); gsub(/mongodb-community/, "MongoDB(Community)", $1); gsub(/mysql/, "MySQL", $1); gsub(/postgresql/, "PostgreSQL", $1); gsub(/redis/, "Redis", $1); print($1)}')
      if [ -n "$check_exists" ]; then
        # Service is installed, check if it is running
        check_service=$(ps aux | grep -o "$service" | wc -l)
        if [ "$check_service" -gt 1 ]; then
          # Service is running
          echo "-> \033[1m$servicename\033[0m is \033[1m\033[32mrunning\033[0m\033[0m"
        else
          # Service is not running
          echo "-> \033[1m$servicename\033[0m is \033[1m\033[31mstopped\033[0m\033[0m"
        fi
      fi
    done
    echo # empty line ;)
    fi

    if [ "$1" = "db" ] && [ -z "$2" ]; then
    # Define array of services
    services=("mongodb-community" "mysql" "postgresql" "redis")
    # Loop through list of services and sheck status of each 
    echo # empty line ;)
    for service in "${services[@]}"; do
      # Check if service is installed
      check_exists=$(brew list | grep "$service")
      # Use awk to modify service name
      servicename=$(echo "$service" | awk '{gsub(/php/, "PHP", $1); gsub(/nginx/, "Nginx", $1); gsub(/mongodb-community/, "MongoDB(Community)", $1); gsub(/mysql/, "MySQL", $1); gsub(/postgresql/, "PostgreSQL", $1); gsub(/redis/, "Redis", $1); print($1)}')
      if [ -z "$check_exists" ]; then
        # Service is not installed
        if [ "$service" = "mongodb-community" ]; then
            echo "-> \033[1m$servicename\033[0m is \033[1m\033[31mnot installed\033[0m\033[0m (how to install - type: \033[4m\033[3mdev mongo\033[0m\033[0m)"
        else
            echo "-> \033[1m$servicename\033[0m is \033[1m\033[31mnot installed\033[0m\033[0m (to install - type: \033[4m\033[3mbrew install $service\033[0m\033[0m)"
        fi
      else
        # Service is installed, check if it is running
        check_service=$(ps aux | grep -o "$service" | wc -l)
        if [ "$check_service" -gt 1 ]; then
          # Service is running
          echo "-> \033[1m$servicename\033[0m is \033[1m\033[32mrunning\033[0m\033[0m \033[3m(to stop, type: \033[4mdev $service stop\033[0m)\033[0m"
        else
          # Service is not running
          echo "-> \033[1m$servicename\033[0m is \033[1m\033[31mstopped\033[0m\033[0m \033[3m(to start, type: \033[4mdev $service start\033[0m)"
        fi
      fi
    done
    echo # empty line ;)
    echo "If you want to install all available databases,"
    echo "that are not installed yet - type: \033[4m\033[3mdev db install\033[0m\033[0m"
    echo # empty line ;)
    elif [ "$1" = "db" ] && [ "$2" = "install" ]; then
    # Define array of services
    services=("mongodb-community" "mysql" "postgresql" "redis")
    for service in "${services[@]}"; do
      # Check if service is installed
      check_exists=$(brew list | grep "$service")
      if [ -z "$check_exists" ]; then
        if [ "$service" = "mongodb-community" ]; then
          # Install MongoDB using the mongodb/brew tap
          brew tap mongodb/brew
          brew install mongodb-community
        else
          # Install service using homebrew
          brew install $service
        fi
      fi
    done
    elif [ "$1" = "db" ] && [ "$2" = "start" ] || [ "$1" = "db" ] && [ "$2" = "stop" ] || [ "$1" = "db" ] && [ "$2" = "restart" ]; then
      # Start, stop, or restart db's
      services=("mongodb-community" "mysql" "postgresql" "redis")
      case "$2" in
        start)
          for service in "${services[@]}"; do
          check_exists=$(brew list | grep "$service")
          if [ -n "$check_exists" ]; then
          brew services start $service
          fi
          done
          ;;
        stop)
          for service in "${services[@]}"; do
          check_exists=$(brew list | grep "$service")
          if [ -n "$check_exists" ]; then
          brew services stop $service
          fi
          done
          ;;
        restart)
          for service in "${services[@]}"; do
          check_exists=$(brew list | grep "$service")
          if [ -n "$check_exists" ]; then
          brew services restart $service
          fi
          done
          ;;
        *)
          echo "[Error] Invalid command. Please use: start, stop, or restart."
          ;;
      esac
      dev status
    fi

    if [ "$1" = "mongo" ] && [ -z "$2" ] || [ "$1" = "mysql" ] && [ -z "$2" ]  || [ "$1" = "postgresql" ] && [ -z "$2" ] || [ "$1" = "redis" ] && [ -z "$2" ]; then
      if [ "$1" = "mongo" ]; then
        check_exists=$(brew list | grep "mongodb-community") service_name="MongoDB(Community)" service="mongo"
      else
        check_exists=$(brew list | grep "$1")
        if [ "$1" = "mysql" ]; then service_name="MySQL" service="mysql" fi
        if [ "$1" = "postgresql" ]; then service_name="PostgreSQL" service="postgresql" fi
        if [ "$1" = "redis" ]; then service_name="Redis" service="redis" fi
      fi
      if [ -n "$check_exists" ]; then
        echo # empty line ;)
        echo "To run $service_name only, type in: \033[4m\033[3mdev $service start\033[0m\033[0m"
        echo "To run all the databases you have installed, type: \033[4m\033[3mdev db start\033[0m\033[0m"
        echo # empty line ;)   
      fi
      if [ -z "$check_exists" ] && [ "$1" = "mongo" ]; then
        echo # empty line ;)
        echo "\033[1mIt looks like your system does not have MongoDB installed ;(\033[0m"
        echo # empty line ;)
        echo "# You can install MongoDB using the mongodb/brew tap"
        echo # empty line ;)
        echo "\033[3mbrew tap \033[4mmongodb/brew\033[0m\033[0m"
        echo "\033[3mbrew install \033[4mmongodb-community\033[0m\033[0m"
        echo # empty line ;)
        echo "also \033[4mNoSQLBooster\033[0m for MongoDB is recommended"
        echo # empty line ;)
        echo "\033[3mbrew install --cask \033[4mnosqlbooster-for-mongodb\033[0m\033[0m"
        echo # empty line ;)
      else
        echo # empty line ;)
        echo "\033[1mIt looks like your system does not have $service_name installed ;(\033[0m"
        echo # empty line ;)
        echo "You can install $service_name by typing: \033[4m\033[3mbrew install $service\033[0m\033[0m"
        echo # empty line ;)
      fi
    elif [ "$1" = "start" ] && [ -z "$2" ] || [ "$1" = "stop" ] && [ -z "$2" ]  || [ "$1" = "restart" ] && [ -z "$2" ]; then
      # Start, stop, or restart service
      case "$1" in
        start)
          brew services start php
          sudo nginx
          ;;
        stop)
          brew services stop php
          sudo nginx -s quit
          ;;
        restart)
          brew services restart php
          sudo nginx -s reload
          ;;
      esac
      dev status
    elif [ "$1" = "start" ] && [ -n "$2" ] || [ "$1" = "stop" ] && [ -n "$2" ]  || [ "$1" = "restart" ] && [ -n "$2" ]; then

      # Start, stop, or restart service
      case "$1" in
        start)
          # Start specified service
          check_service=$(ps aux | grep -o "$2" | wc -l)
          if [ "$check_service" -le 1 ]; then
          if [ "$2" = "nginx" ]; then
          sudo nginx
          else
          brew services start $2
          fi 
          else
          echo # empty line ;) 
          echo "\033[1mUnexpected Error:\033[0m check if \033[1m\033[3m$2\033[0m\033[0m is installed on the system."
          echo "Type the following command, to check if the package is installed: \033[4mbrew services list\033[0m"
          echo # empty line ;)                   
          fi  
          ;;
        stop)
          # Stop specified service
          check_service=$(ps aux | grep -o "$2" | wc -l)
          if [ "$check_service" -gt 1 ]; then
          if [ "$2" = "nginx" ]; then
          sudo nginx -s quit
          else
          brew services stop $2
          fi                   
          fi  
          ;;
        restart)
          # Restart specified service
          check_service=$(ps aux | grep -o "$2" | wc -l)
          if [ "$check_service" -gt 1 ]; then
          if [ "$2" = "nginx" ]; then
          sudo nginx -s reload
          else
          brew services restart $2
          fi                    
          fi  
          ;;
      esac
    fi

  fi
}
