# Reload bash stuff
alias reload='. ~/.zshrc'

# Generate a random password of 24 characters
alias getpasswd='echo `env LC_CTYPE=C tr -dc "A-Za-z0-9.$&^@!;" < /dev/urandom | head -c 24`'

function dev() {
    if [ "$1" = "start" ]; then
        if [ -z "$2" ]; then
            # No service specified, start all services
            if [ $(brew list | grep nginx) ]; then
                brew services start nginx
                echo "nginx service.. [started]"
            fi
            if [ $(brew list | grep php) ]; then
                brew services start php
                echo "PHP service.. [started]"
            fi
            if [ $(brew list | grep mongodb) ]; then
                brew services start mongodb
                echo "MongoDB service.. [started]"
            fi
            if [ $(brew list | grep mysql) ]; then
                brew services start mysql
                echo "MySQL service.. [started]"
            fi
            if [ $(brew list | grep postgresql) ]; then
                brew services start postgresql
                echo "PostgreSQL service.. [started]"
            fi                        
        else
            # Start specified service(s)
            brew services start $2
            echo "$2 service.. [started]"
        fi
    elif [ "$1" = "stop" ]; then
        if [ -z "$2" ]; then
            # No service specified, stop all services
            if [ $(brew services list | grep nginx) ]; then
                brew services stop nginx
                echo "nginx service - stopped!"
            fi
            if [ $(brew services list | grep php) ]; then
                brew services stop php
                echo "PHP service - stopped!"
            fi
            if [ $(brew services list | grep mongodb) ]; then
                brew services stop mongodb
                echo "MongoDB service - stopped!"
            fi
            if [ $(brew services list | grep mysql) ]; then
                brew services stop mysql
                echo "MySQL service - stopped!"
            fi
            if [ $(brew services list | grep postgresql) ]; then
                brew services stop postgresql
                echo "PostgreSQL service - stopped!"
            fi             
        else
            # Stop specified service(s)
            brew services stop $2
            echo "$2 service - stoped!"
        fi
    elif [ "$1" = "restart" ]; then
        if [ -z "$2" ]; then
            # No service specified, restart all services
            if [ $(brew list | grep nginx) ]; then
                brew services restart nginx
            fi
            if [ $(brew list | grep php) ]; then
                brew services restart php
            fi
            if [ $(brew list | grep mongodb) ]; then
                brew services restart mongodb
            fi
            if [ $(brew list | grep mysql) ]; then
                brew services restart mysql
            fi
            if [ $(brew list | grep postgresql) ]; then
                brew services restart postgresql
            fi 
        else
            # Restart specified service(s)
            brew services restart $2
        fi
    else
        # List available services
        echo -e "Available services: $(brew list | grep nginx) $(brew list | grep php) $(brew list | grep mongodb) $(brew list | grep mysql) $(brew list | grep postgresql)\n"
        echo -e "Usage: dev start|stop|restart [service(s)]\r\n"
        echo -e "To start both the nginx and php services, you can run the following command:\n"
        echo -e "dev start nginx php\n"
    fi
}
