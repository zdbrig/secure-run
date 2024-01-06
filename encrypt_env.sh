#!/bin/bash

# Script to encrypt the .env file with password confirmation and complexity check

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL could not be found. Please install it."
    exit 1
fi

# Function to check password complexity
check_password_complexity() {
    local password=$1
    if [[ ${#password} -lt 8 ]]; then
        echo "Password too short. Must be at least 8 characters."
        return 1
    fi
    if ! [[ $password =~ [0-9] ]]; then
        echo "Password must include at least one number."
        return 1
    fi
    if ! [[ $password =~ [a-zA-Z] ]]; then
        echo "Password must include both uppercase and lowercase letters."
        return 1
    fi
    if ! [[ $password =~ [[:punct:]] ]]; then
        echo "Password must include at least one special character."
        return 1
    fi
    return 0
}

# Prompt for the encryption password and confirm it
while true; do
    read -sp 'Enter a secure password for encryption: ' ENCRYPTION_PASSWORD
    echo
    read -sp 'Confirm your password: ' CONFIRM_PASSWORD
    echo
    if [[ $ENCRYPTION_PASSWORD == $CONFIRM_PASSWORD ]]; then
        if check_password_complexity "$ENCRYPTION_PASSWORD"; then
            break
        fi
    else
        echo "Passwords do not match. Please try again."
    fi
done

# Defining the file names
ENV_FILE="envorigin"
ENCRYPTED_FILE=".env.enc"

# Encrypt the .env file
openssl enc -aes-256-cbc -salt -in "$ENV_FILE" -out "$ENCRYPTED_FILE" -pass pass:"$ENCRYPTION_PASSWORD"

# Check if the .env file was encrypted successfully
if [ -f "$ENCRYPTED_FILE" ]; then
    echo "Your .env file has been encrypted to $ENCRYPTED_FILE"
else
    echo "Failed to encrypt the .env file."
    exit 1
fi
