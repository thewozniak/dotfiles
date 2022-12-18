# Reload bash stuff
alias reload='. ~/.zshrc'

# Generate a random password of 24 characters
alias getpasswd='echo `env LC_CTYPE=C tr -dc "A-Za-z0-9.$&^@!;" < /dev/urandom | head -c 24`'

function dev() {
    if [ "$1" = "start" ]; then
        if [ -z "$2" ]; then
            # No service specified, start all services
            if [ $(brew services list | grep nginx | awk '// {print $1}') == "nginx" ]; then
                brew services start nginx
            fi
            if [ $(brew services list | grep php | awk '// {print $1}') == "php" ]; then
                brew services start php
            fi
            if [ $(brew services list | grep mongodb-community | awk '// {print $1}') == "mongodb-community" ]; then
                brew services start mongodb-community
            fi
            if [ $(brew services list | grep mysql | awk '// {print $1}') == "mysql" ]; then
                brew services start mysql
            fi
            if [ $(brew services list | grep postgresql | awk '// {print $1}') == "postgresql" ]; then
                brew services start postgresql
            fi                        
        else
            # Start specified service(s)
            brew services start $2
        fi
    elif [ "$1" = "stop" ]; then
        if [ -z "$2" ]; then
            # No service specified, stop all services
            if [ $(brew services list | grep nginx | awk '/started/ {print $2}') == "started" ]; then
                brew services stop nginx
            fi
            if [ $(brew services list | grep php | awk '/started/ {print $2}') == "started" ]; then
                brew services stop php
            fi
            if [ $(brew services list | grep mongodb-community | awk '/started/ {print $2}') == "started" ]; then
                brew services stop mongodb-community
            fi
            if [ $(brew services list | grep mysql | awk '/started/ {print $2}') == "started" ]; then
                brew services stop mysql
            fi
            if [ $(brew services list | grep postgresql | awk '/started/ {print $2}') == "started" ]; then
                brew services stop postgresql
            fi             
        else
            # Stop specified service(s)
            brew services stop $2
        fi
    elif [ "$1" = "restart" ]; then
        if [ -z "$2" ]; then
            # No service specified, restart all services
            if [ $(brew services list | grep nginx | awk '/started/ {print $2}') == "started" ]; then
                brew services restart nginx
            fi
            if [ $(brew services list | grep php | awk '/started/ {print $2}') == "started" ]; then
                brew services restart php
            fi
            if [ $(brew services list | grep mongodb-community | awk '/started/ {print $2}') == "started" ]; then
                brew services restart mongodb-community
            fi
            if [ $(brew services list | grep mysql | awk '/started/ {print $2}') == "started" ]; then
                brew services restart mysql
            fi
            if [ $(brew services list | grep postgresql | awk '/started/ {print $2}') == "started" ]; then
                brew services restart postgresql
            fi 
        else
            # Restart specified service(s)
            brew services restart $2
        fi
    else
        # List available services
        echo # empty line ;)
        echo "Available services: $(brew list | grep nginx) $(brew list | grep php) $(brew list | grep mongodb) $(brew list | grep mysql) $(brew list | grep postgresql)"
        echo # empty line ;)
        echo "Usage: dev start|stop|restart [service(s)]"
        echo # empty line ;)
        echo "To start both the nginx and php services, you can run the following command:"
        echo "dev start nginx php"
    fi
}
