# Reload bash stuff
alias reload='. ~/.zshrc'

# Generate a random password of 24 characters
alias getpasswd='echo `env LC_CTYPE=C tr -dc "A-Za-z0-9.$&^@!;" < /dev/urandom | head -c 24`'

function dev() {

# Ask for the administrator password upfront
sudo -v

phpcheck=$(ps aux | grep -o 'php' | wc -l)
nginxcheck=$(ps aux | grep -o 'nginx' | wc -l)
dnsmasqcheck=$(ps aux | grep -o 'dnsmasq' | wc -l)
mongocheck=$(ps aux | grep -o 'mongodb-community' | wc -l)
mongocheckexist=$(brew list | grep 'mongodb-community')
mysqlcheck=$(ps aux | grep -o 'mysql' | wc -l)
mysqlcheckexist=$(brew list | grep 'mysql')
postsqlcheck=$(ps aux | grep -o 'postgresql' | wc -l)
postsqlcheckexist=$(brew list | grep 'postgresql')
redischeck=$(ps aux | grep -o 'redis' | wc -l)
redischeckexist=$(brew list | grep 'redis')

    if [ "$1" = "start" ]; then
        if [ -z "$2" ]; then
            # No service specified, start all services
            if [ "$dnsmasqcheck" -le 1 ]; then
              sudo brew services start dnsmasq
            fi             
            if [ "$phpcheck" -le 1 ]; then
              brew services start php
            fi                      
            if [ "$nginxcheck" -le 1 ]; then
              sudo nginx
            fi
            if [ -n "$mongocheckexist" ] && [ "$mongocheck" -le 1 ]; then
              brew services start mongodb-community
            fi
            if [ -n "$mysqlcheckexist" ] && [ "$mysqlcheck" -le 1 ]; then
              brew services start mysql
            fi
            if [ -n "$postsqlcheckexist" ] && [ "$postsqlcheck" -le 1 ]; then
              brew services start postgresql
            fi
            if [ -n "$redischeckexist" ] && [ "$redischeck" -le 1 ]; then
              brew services start redis
            fi
            dev status                
        else
            # Start specified service(s)
            check_service=$(ps aux | grep -o '$2' | wc -l)
            check_exists=$(brew list | grep '$2')
            if [ -n "$check_exists" ] && [ "$check_service" -le 1 ]; then
              #brew services start $2
              brew services start $2
            else
              echo # empty line ;) 
              echo "\033[1mUnexpected Error:\033[0m check if \033[1m\033[3m$2\033[0m\033[0m is installed on the system."
              echo "Type the following command, to check if the package is installed: \033[4mbrew services list\033[0m"
              echo # empty line ;)                   
            fi              
        fi
    elif [ "$1" = "stop" ]; then
        if [ -z "$2" ]; then
            # No service specified, stop all services
            if [ "$phpcheck" -gt 1 ]; then
              brew services stop php
            fi                      
            if [ "$nginxcheck" -gt 1 ]; then
              sudo nginx -s quit
            fi
            if [ -n "$mongocheckexist" ] && [ "$mongocheck" -gt 1 ]; then
              brew services stop mongodb-community
            fi
            if [ -n "$mysqlcheckexist" ] && [ "$mysqlcheck" -gt 1 ]; then
              brew services stop mysql
            fi
            if [ -n "$postsqlcheckexist" ] && [ "$postsqlcheck" -gt 1 ]; then
              brew services stop postgresql
            fi
            if [ -n "$redischeckexist" ] && [ "$redischeck" -gt 1 ]; then
              brew services stop redis
            fi   
            dev status            
        else
            check_service=$(ps aux | grep -o '$2' | wc -l)
            check_exists=$(brew list | grep '$2')
            if [ -n "$check_exists" ] && [ "$check_service" -gt 1 ]; then
              brew services stop $2
            fi    
        fi
    elif [ "$1" = "restart" ]; then
        if [ -z "$2" ]; then
            # No service specified, restart all services
            if [ "$dnsmasqcheck" -gt 1 ]; then
              sudo brew services restart dnsmasq
            fi              
            if [ "$phpcheck" -gt 1 ]; then
              brew services restart php
            fi                      
            if [ "$nginxcheck" -gt 1 ]; then
              sudo nginx -s reload
            fi
            if [ -n "$mongocheckexist" ] && [ "$mongocheck" -gt 1 ]; then
              brew services restart mongodb-community
            fi
            if [ -n "$mysqlcheckexist" ] && [ "$mysqlcheck" -gt 1 ]; then
              brew services restart mysql
            fi
            if [ -n "$postsqlcheckexist" ] && [ "$postsqlcheck" -gt 1 ]; then
              brew services restart postgresql
            fi
            if [ -n "$redischeckexist" ] && [ "$redischeck" -gt 1 ]; then
              brew services restart redis
            fi
            dev status     
        else
            check_service=$(ps aux | grep -o '$2' | wc -l)
            check_exists=$(brew list | grep '$2')
            if [ -n "$check_exists" ] && [ "$check_service" -gt 1 ]; then
              brew services restart $2
            fi 
        fi
    elif [ "$1" = "mongo" ] || [ "$1" = "mysql" ] || [ "$1" = "postgresql" ] || [ "$1" = "redis" ]; then
        if [ -z "$2" ]; then
            # No command specified
            if [ "$1" = "mongo" ]; then
              check_exists=$(brew list | grep 'mongodb-community')
              service_name="MongoDB(Community)"
              service="mongo"
            else
              check_exists=$(brew list | grep '$1')
              if [ "$1" = "mysql" ]; then
              service_name="MySQL"
              service="mysql"
              fi
              if [ "$1" = "postgresql" ]; then
              service_name="PostgreSQL"
              service="postgresql"
              fi
              if [ "$1" = "redis" ]; then
              service_name="Redis"
              service="redis"
              fi
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
        else
            if [ "$1" = "mongo" ]; then
            check_service=$(ps aux | grep -o 'mongodb-community' | wc -l)
            check_exists=$(brew list | grep 'mongodb-community')
            service="mongodb-community"
            else
            check_service=$(ps aux | grep -o '$1' | wc -l)
            check_exists=$(brew list | grep '$1')
            service=$1
            fi
            if [ "$2" = "start" ]; then
                if [ -n "$check_exists" ] && [ "$check_service" -le 1 ]; then
                    brew services start $service
                    dev status
                else
                    dev $1
                fi
            fi               
            if [ "$2" = "stop" ]; then
                if [ -n "$check_exists" ] && [ "$check_service" -le 1 ]; then
                    brew services stop $service
                    dev status
                else
                    dev $1
                fi
            fi  
            if [ "$2" = "restart" ]; then
                if [ -n "$check_exists" ] && [ "$check_service" -le 1 ]; then
                    brew services restart $service
                    dev status
                else
                    dev $1
                fi
            fi                            
        fi
    elif [ "$1" = "db" ]; then
        if [ -z "$2" ]; then
            echo # empty line ;)
            # check which db's are installed
            if [ -n "$mongocheckexist" ]; then
              echo "\033[1mMongoDB(Community)\033[0m is \033[32minstalled\033[0m"
            else
              echo "\033[1mMongoDB(Community)\033[0m is \033[31mnot installed\033[0m (how to install - type: \033[4m\033[3mdev mongo\033[0m\033[0m)"
            fi
            if [ -n "$mysqlcheckexist" ]; then
              echo "\033[1mMySQL\033[0m is \033[32minstalled\033[0m"
            else
              echo "\033[1mMySQL\033[0m is \033[31mnot installed\033[0m (to install - type: \033[4m\033[3mbrew install mysql\033[0m\033[0m)"
            fi
            if [ -n "$postqlcheckexist" ]; then
              echo "\033[1mPostgreSQL\033[0m is \033[32minstalled\033[0m"
            else
              echo "\033[1mPostgreSQL\033[0m is \033[31mnot installed\033[0m (to install - type: \033[4m\033[3mbrew install postgresql\033[0m\033[0m)"
            fi
            if [ -n "$redischeckexist" ]; then
              echo "\033[1mRedis\033[0m is \033[32minstalled\033[0m"
            else
              echo "\033[1mRedis\033[0m is \033[31mnot installed\033[0m (to install - type: \033[4m\033[3mbrew install redis\033[0m\033[0m)"
            fi
            echo # empty line ;)
            echo "If you want to install all databases, type: \033[4m\033[3mdev db install\033[0m\033[0m"
            echo # empty line ;)
        else
            if [ "$2" = "start" ]; then    
            # start db's
                if [ -n "$mongocheckexist" ]; then
                    brew services start mongodb-community
                fi
                if [ -n "$mysqlcheckexist" ]; then
                    brew services start mysql
                fi
                if [ -n "$postsqlcheckexist" ]; then
                    brew services start postgresql
                fi
                if [ -n "$redischeckexist" ]; then
                    brew services start redis
                fi
            fi
            if [ "$2" = "stop" ]; then    
            # stop db's
                if [ -n "$mongocheckexist" ] && [ "$mongocheck" -gt 1 ]; then
                    brew services stop mongodb-community
                fi
                if [ -n "$mysqlcheckexist" ] && [ "$mysqlcheck" -gt 1 ]; then
                    brew services stop mysql
                fi
                if [ -n "$postsqlcheckexist" ] && [ "$postsqlcheck" -gt 1 ]; then
                    brew services stop postgresql
                fi
                if [ -n "$redischeckexist" ] && [ "$redischeck" -gt 1 ]; then
                    brew services stop redis
                fi 
            fi
            if [ "$2" = "restart" ]; then    
            # restart db's
                if [ -n "$mongocheckexist" ] && [ "$mongocheck" -gt 1 ]; then
                    brew services restart mongodb-community
                fi
                if [ -n "$mysqlcheckexist" ] && [ "$mysqlcheck" -gt 1 ]; then
                    brew services restart mysql
                fi
                if [ -n "$postsqlcheckexist" ] && [ "$postsqlcheck" -gt 1 ]; then
                    brew services restart postgresql
                fi
                if [ -n "$redischeckexist" ] && [ "$redischeck" -gt 1 ]; then
                    brew services restart redis
                fi             
            fi
            if [ "$2" = "install" ]; then 
                if [ -z $mongocheckexist ]; then
                    # Install MongoDB using the mongodb/brew tap
                    brew tap mongodb/brew
                    brew install mongodb-community
                fi
                if [ -z $mysqlcheckexist ]; then
                    # Install MySQL using homebrew
                    brew install mysql
                fi
                if [ -z $postsqlcheckexist ]; then
                    # Install MySQL using homebrew
                    brew install postgresql
                fi
                if [ -z $redischeckexist ]; then
                    # Install MySQL using homebrew
                    brew install redis
                fi
            fi                                           
        fi
    elif [ "$1" = "status" ]; then
            echo # empty line ;)
            if [ "$phpcheck" -gt 1 ]; then
              echo "-> \033[1mPHP\033[0m is \033[1m\033[32mrunning\033[0m\033[0m"
            fi                      
            if [ "$nginxcheck" -gt 1 ]; then
              echo "-> \033[1mNginx\033[0m is \033[1m\033[32mrunning\033[0m\033[0m"
            fi
            if [ "$mongocheck" -gt 1 ]; then
              echo "-> \033[1mMongoDB\033[0m is \033[1m\033[32mrunning\033[0m\033[0m \033[3m(to stop type: \033[4mdev stop mongodb-community\033[0m)\033[0m"
            fi
             if [ -n "$mongocheckexist" ] && [ "$mongocheck" -gt 1 ]; then
              echo "-> \033[1mMongoDB\033[0m is \033[1m\033[32mrunning\033[0m\033[0m \033[3m(to stop type: \033[4mdev stop mongodb-community\033[0m)\033[0m"
            fi  
            if [ -n "$mysqlcheckexist" ] && [ "$mysqlcheck" -gt 1 ]; then
              echo "-> \033[1mMySQL\033[0m is \033[1m\033[32mrunning\033[0m\033[0m \033[3m(to stop type: \033[4mdev stop mysql\033[0m)\033[0m"
            fi  
            if [ -n "$postsqlcheckexist" ] && [ "$postsqlcheck" -gt 1 ]; then
              echo "-> \033[1mPostgreSQL\033[0m is \033[1m\033[32mrunning\033[0m\033[0m \033[3m(to stop type: \033[4mdev stop postgresql\033[0m)\033[0m"
            fi
            if [ -n "$redischeckexist" ] && [ "$redischeck" -gt 1 ]; then
              echo "-> \033[1mRedis\033[0m is \033[1m\033[32mrunning\033[0m\033[0m \033[3m(to stop type: \033[4mdev stop redis\033[0m)\033[0m"
            fi                                                                     
            if [ "$phpcheck" -le 1 ]; then
              echo "-> \033[1mPHP\033[0m is \033[1m\033[31mnot running\033[0m\033[0m"
            fi                      
            if [ "$nginxcheck" -le 1 ]; then
              echo "-> \033[1mNginx\033[0m is \033[1m\033[31mnot \033[1m\033[31mrunning\033[0m\033[0m"
            fi  
            if [ -n "$mongocheckexist" ] && [  "$mongocheck" -le 1 ]; then
              echo "-> \033[1mMongoDB\033[0m is \033[1m\033[31mnot running\033[0m\033[0m \033[3m(to start type: \033[4mdev start mongodb-community\033[0m)\033[0m"
            fi  
            if [ -n "$mysqlcheckexist" ] && [ "$mysqlcheck" -le 1 ]; then
              echo "-> \033[1mMySQL\033[0m is \033[1m\033[31mnot running\033[0m\033[0m \033[3m(to start type: \033[4mdev start mysql\033[0m)\033[0m"
            fi  
            if [ -n "$postsqlcheckexist" ] && [ "$postsqlcheck" -le 1 ]; then
              echo "-> \033[1mPostgreSQL\033[0m is \033[1m\033[31mnot running\033[0m\033[0m \033[3m(to start type: \033[4mdev start postgresql\033[0m)\033[0m"
            fi
            if [ -n "$redischeckexist" ] && [ "$redischeck" -le 1 ]; then
              echo "-> \033[1mRedis\033[0m is \033[1m\033[31mnot running\033[0m\033[0m \033[3m(to start type: \033[4mdev start redis\033[0m)\033[0m"
            fi
            echo # empty line ;)                                                     
    else
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
    fi
}
