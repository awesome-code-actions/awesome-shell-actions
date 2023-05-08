#!bin/bash

function dns-install() {
  sudo apt-get install pdns-server
  docker run --network=host -e BIND_ADDRESS=0.0.0.0:9191 -e SECRET_KEY='a-very-secret-key'  -v pda-data:/data  powerdnsadmin/pda-legacy:latest
}
