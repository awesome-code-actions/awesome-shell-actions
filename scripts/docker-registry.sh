#!/bin/bash

function docker-registry-http() {
    docker stop registry-http
    docker rm registry-http
    docker run \
        -e REGISTRY_LOG_LEVEL=info \
        -e OTEL_TRACES_EXPORTER=none \
        -e OTEL_METRICS_EXPORTER=none \
        -e OTEL_LOGS_EXPORTER=none \
        -d \
        -p 5080:5000 \
        --name registry-http \
        --restart=always \
        -v /data/registry-http:/var/lib/registry \
        registry:3 ; \
    docker logs -f registry-http
    docker tag golang:1.25rc2-bullseye  outside.http.local:5080/golang:1.25rc2-bullseye
    # add  outside.http.local:5080 to /etc/docker/daemon.json
    docker push  outside.http.local:5080/golang:1.25rc2-bullseye
}

function docker-registry-https() {
    docker stop registry-https;
    docker rm registry-https ;

    openssl req -newkey rsa:4096 -nodes -sha256 \
        -keyout ./certs/tls.key \
        -x509 -days 365 \
        -subj "/C=GR/ST=./L=./O=./CN=outside.https.local" \
        -addext "subjectAltName = DNS:outside.https.local" \
        -out ./certs/tls.crt

    docker run \
        -e REGISTRY_LOG_LEVEL=info \
        -e OTEL_TRACES_EXPORTER=none \
        -e OTEL_METRICS_EXPORTER=none \
        -e OTEL_LOGS_EXPORTER=none \
        -d \
        -p 5443:5000 \
        --name registry-https \
        --restart=always \
        -v $PWD/certs:/certs \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/tls.crt \
        -e REGISTRY_HTTP_TLS_KEY=/certs/tls.key \
        -v $PWD/registry-https:/var/lib/registry \
        registry:3

    docker logs -f registry-http
    
    docker tag golang:1.25rc2-bullseye  outside.https.local:5443/golang:1.25rc2-bullseye
    # add  outside.https.local:5443 to /etc/docker/daemon.json
    docker push  outside.https.local:5443/golang:1.25rc2-bullseye
}
