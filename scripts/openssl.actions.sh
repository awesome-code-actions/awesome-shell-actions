#!/usr/bin/env bash

function openssl-gen-cert() {
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout example.key -out example.crt -subj "/CN=example.com" \
    -addext "subjectAltName=DNS:example.com,DNS:www.example.net,IP:10.0.0.1"
  openssl rsa -in example.key -out example-rsa.key
}

function openssl-gen-cert-expired() {
  # Step 1: Save the current date
  current_date=$(date -u)

  # Step 2: Set the system date to a past date
  sudo date --set="2000-01-01"

  # Step 3: Create the certificate
  openssl req -x509 -newkey rsa:4096 -sha256 -days 1 -nodes \
    -keyout example.key -out example.crt -subj "/CN=example.com" \
    -addext "subjectAltName=DNS:example.com,DNS:www.example.net,IP:10.0.0.1"
  openssl rsa -in example.key -out example-rsa.key
  # Step 4: Restore the system date
  sudo date --set="$current_date"
}

function openssl-check-cert() {
  set -x
  local domain=$1
  openssl s_client -servername $domain -connect $domain:443 | openssl x509 -noout -dates
}
