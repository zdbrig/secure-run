#!/bin/bash

# Script to decrypt .env.enc, set environment variables in memory, and run the TypeScript Node.js app

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL could not be found. Please install it."
    exit
fi

# Define the encrypted file name
ENCRYPTED_FILE=".env.enc"

# Prompt for the decryption password
read -sp 'Enter the decryption password: ' DECRYPTION_PASSWORD
echo

# Decrypt the .env.enc content directly into a variable
DECRYPTED_CONTENT=$(openssl enc -d -aes-256-cbc -in "$ENCRYPTED_FILE" -pass pass:"$DECRYPTION_PASSWORD" 2>/dev/null)

# Check if the decryption was successful
if [ -z "$DECRYPTED_CONTENT" ]; then
    echo "Failed to decrypt the .env file. Check your password and try again."
    exit 1
fi

# Export the variables in the decrypted content
while IFS='=' read -r key value
do
  # Remove any existing quotes
  value="${value%\"}"
  value="${value#\"}"
  export "$key=$value"
done <<< "$DECRYPTED_CONTENT"

# Run the TypeScript Node.js application
node index.ts
