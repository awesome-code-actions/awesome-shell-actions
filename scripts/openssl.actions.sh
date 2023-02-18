#!/usr/bin/env bash

function openssl-gen-cert () {
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout example.key -out example.crt -subj "/CN=example.com" \
  -addext "subjectAltName=DNS:example.com,DNS:www.example.net,IP:10.0.0.1"
openssl rsa -in example.key  -out example-rsa.key
}

