#!/bin/bash

# Script to decrypt the appropriate .env file based on NODE_ENV, set environment variables in memory, and run the TypeScript Node.js app

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL could not be found. Please install it."
    exit 1
fi

# Define the file names based on NODE_ENV
ENCRYPTED_FILE=".env.enc"


# Prompt for the decryption password
read -sp 'Enter the decryption password: ' DECRYPTION_PASSWORD
echo

# Decrypt the .env file content directly into a variable
DECRYPTED_CONTENT=$(openssl enc -d -aes-256-cbc -md md5 -in "$ENCRYPTED_FILE" -pass pass:"$DECRYPTION_PASSWORD" 2>/dev/null)

# Check if the decryption was successful
if [ -z "$DECRYPTED_CONTENT" ]; then
    echo "Failed to decrypt the $ENCRYPTED_FILE. Check your password and try again."
    exit 1
fi

# Export the variables in the decrypted content
while IFS='=' read -r key value
do
  # Remove any existing quotes and export the variable
  value="${value%\"}"
  value="${value#\"}"
  export "$key=$value"
done <<< "$DECRYPTED_CONTENT"

# Run the TypeScript Node.js application
node index.ts
