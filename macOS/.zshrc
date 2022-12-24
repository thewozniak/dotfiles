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
mysqlcheck=$(ps aux | grep -o 'mysql' | wc -l)
postsqlcheck=$(ps aux | grep -o 'postgresql' | wc -l)
redischeck=$(ps aux | grep -o 'redis' | wc -l)

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
        else
            # Start specified service(s)
            check_service=$(ps aux | grep -o '$2' | wc -l)
            if [ "$check_service" -le 1 ]; then
              #brew services start $2
              brew services start $2                
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
        else
            check_service=$(ps aux | grep -o '$2' | wc -l)
            if [ "$check_service" -gt 1 ]; then
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
        else
            check_service=$(ps aux | grep -o '$2' | wc -l)
            if [ "$check_service" -gt 1 ]; then
              brew services restart $2
            fi 
        fi
    else
        # List available services
        echo # empty line ;)
        echo "Available services: $(brew list | grep nginx) $(brew list | grep php) $(brew list | grep mongodb-community) $(brew list | grep mysql) $(brew list | grep postgresql) $(brew list | grep redis)"
        echo # empty line ;)
        echo "Usage: dev start|stop|restart [service(s)]"
        echo # empty line ;)
        echo "To start DEV-ENV (Nginx with PHP), type the following command:"
        echo "dev start"
        echo # empty line ;)
        echo "To start DEV-ENV additional service(s), for exapmple MongoDB and Redis, type as following:"
        echo "dev start mongodb-community"
        echo "dev start redis"
        echo # empty line ;)        
    fi
}
