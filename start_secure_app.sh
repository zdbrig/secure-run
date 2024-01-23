#!/bin/bash

# Script to decrypt individual values in .env, set environment variables in memory, and run the TypeScript Node.js app

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL could not be found. Please install it."
    exit 1
fi

# Define the .env file name
ENV_FILE="envorigin"
ENCRYPTED_PREFIX="encrypted_"

# Prompt for the decryption password
read -sp 'Enter the decryption password: ' DECRYPTION_PASSWORD
echo

# Decrypt only the encrypted values in the .env file and set them as environment variables
while IFS= read -r line || [[ -n "$line" ]]; do
    key="${line%%=*}"
    value="${line#*=}"

    if [[ "$value" == "$ENCRYPTED_PREFIX"* ]]; then
        encrypted_value="${value#$ENCRYPTED_PREFIX}"
        decrypted_value=$(echo -n "$encrypted_value" | base64 -d | openssl enc -aes-256-cbc -d -salt -md md5 -pass pass:"$DECRYPTION_PASSWORD" 2>/dev/null)
      #  decrypted_value=$(openssl enc -aes-256-cbc -d -in "$encrypted_value" -salt -md md5 -pass pass:"$DECRYPTION_PASSWORD" 2>&1)

        if [ $? -eq 0 ]; then
           
            export "$key=$decrypted_value"
        else
            echo "Failed to decrypt the value for '$key'. Check your password and try again."
            exit 1
        fi
    else
        export "$key=$value"
    fi
done < "$ENV_FILE"

# Run the TypeScript Node.js application
docker compose up
