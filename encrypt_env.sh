
#!/bin/bash

# Script to selectively encrypt values in a .env file

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
TEMP_FILE=".env.tmp"
ENCRYPTED_PREFIX="encrypted_"

# Encrypt only the values in the .env file
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *"$ENCRYPTED_PREFIX"* ]]; then
        echo "$line" >> "$TEMP_FILE"
    elif [[ "$line" == *"="* ]]; then
        key="${line%%=*}"
        value="${line#*=}"
        # Using printf to avoid issues with echo and command-line flags
        encrypted_value=$(printf "%s" "$value" | openssl enc -aes-256-cbc -salt -md md5 -pass pass:"$ENCRYPTION_PASSWORD" | base64)
        echo "${key}=${ENCRYPTED_PREFIX}${encrypted_value}" >> "$TEMP_FILE"
    else
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$ENV_FILE"

# Replace original file with encrypted file
mv "$TEMP_FILE" "$ENV_FILE"

echo "Your .env file has been updated with encrypted values."
