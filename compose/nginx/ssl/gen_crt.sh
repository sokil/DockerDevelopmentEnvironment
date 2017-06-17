#!/usr/bin/env bash

# Generate certificate request

# Private key
KEY_FILE="nginx.key"

# Certificate request key
CSR_FILE="nginx.csr"

# Certificate key
CRT_FILE="nginx.crt"

# Generate private key
openssl genrsa -des3 -out $KEY_FILE 2048

# Check private key
openssl rsa -noout -text -in $KEY_FILE

# Remove passphrase from private key
# openssl rsa -in $KEY_FILE -out "decrypted.${KEY_FILE}"

# Generate certificate signing request
openssl req -new -key $KEY_FILE -out $CSR_FILE

# Check certificate request
openssl req -noout -text -in $CSR_FILE

# Generate self-signed certificate
openssl x509 \
    -req \
    -days 365 \
    -in $CSR_FILE \
    -signkey $KEY_FILE \
    -out $CRT_FILE

# Check fingerprint
openssl x509 \
    -noout \
    -fingerprint \
    -in $CRT_FILE