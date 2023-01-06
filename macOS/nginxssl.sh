#!/bin/sh

echo "mamas, papas, dupas, bladas"

function nginxssl() {
sudo -v  
    wget https://woz.ooo/dl/dotfiles/macOS/nginx-server-template.conf -O /usr/local/etc/nginx/servers/$1.conf
    perl -i -pe "s:{{host}}:$1:; s:{{root}}:${HOME}/Sites/$1:" /usr/local/etc/nginx/servers/$1.conf
    mkdir ${HOME}/Sites/$1
    sudo chmod -R 775 ${HOME}/Sites/$1
    openssl req \
        -x509 -sha256 -nodes -newkey rsa:2048 -days 3650 \
        -subj "/CN=$1" \
        -reqexts SAN \
        -extensions SAN \
        -config <(cat /System/Library/OpenSSL/openssl.cnf; printf "[SAN]\nsubjectAltName=DNS:$1") \
        -keyout /usr/local/etc/nginx/ssl/$1.key \
        -out /usr/local/etc/nginx/ssl/$1.crt
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /usr/local/etc/nginx/ssl/$1.crt  
}
