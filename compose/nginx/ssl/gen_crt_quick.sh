#!/usr/bin/env bash

# Generate certificate request

# Private key
KEY_FILE="nginx.key"

# Certificate key
CRT_FILE="nginx.crt"

# Generate self signed certificate
openssl req \
    -newkey rsa:2048 \
    -new \
    -x509 \
    -days 3652 \
    -nodes \
    -out $CRT_FILE \
    -keyout $KEY_FILE