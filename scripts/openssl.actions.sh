#!/usr/bin/env bash

function openssl-gen-cert () {
    local key=$1
    local cert=$2
    openssl req -x509 -newkey rsa:4096 -keyout $key -out $cert -sha256 -days 365 -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=www.example.com"
}

