#!/usr/bin/env bash
function goaccess-install() {
  wget https://tar.goaccess.io/goaccess-1.7.tar.gz
  tar -xzvf goaccess-1.7.tar.gz
  sudo apt install libmaxminddb-dev
  cd goaccess-1.7/
  ./configure --enable-utf8 --enable-geoip=mmdb
  make
  make install
}
