#!/bin/bash

# Script to decrypt the .env.enc file with password confirmation

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL could not be found. Please install it."
    exit 1
fi

# Prompt for the decryption password
read -sp 'Enter your password for decryption: ' DECRYPTION_PASSWORD
echo

# Defining the file names
ENCRYPTED_FILE=".env.enc"
DECRYPTED_FILE="envorigin"

# Decrypt the .env.enc file
openssl enc -aes-256-cbc -d -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" -pass pass:"$DECRYPTION_PASSWORD"

# Check if the .env file was decrypted successfully
if [ -f "$DECRYPTED_FILE" ]; then
    echo "Your .env file has been decrypted to $DECRYPTED_FILE"
else
    echo "Failed to decrypt the .env file. Check your password and try again."
    exit 1
fi
