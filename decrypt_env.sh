
#!/bin/bash

# Script to selectively decrypt values in a .env file

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
ENV_FILE="envorigin"
TEMP_FILE=".env.tmp"
ENCRYPTED_PREFIX="encrypted_"
DECODED_FILE=".env.decoded"

# Decrypt only the encrypted values in the .env file
while IFS= read -r line || [[ -n "$line" ]]; do
    key="${line%%=*}"
    value="${line#*=}"

    if [[ "$value" == "$ENCRYPTED_PREFIX"* ]]; then
        encrypted_value="${value#$ENCRYPTED_PREFIX}"
        echo "$encrypted_value" | base64 -d > "$DECODED_FILE"
        if [ $? -ne 0 ]; then
            echo "Failed to base64 decode the value for '$key'."
            exit 1
        fi

        decrypted_value=$(openssl enc -aes-256-cbc -d -in "$DECODED_FILE" -salt -md md5 -pass pass:"$DECRYPTION_PASSWORD" 2>&1)
        exit_status=$?
        if [ $exit_status -eq 0 ]; then
            echo "${key}=${decrypted_value}" >> "$TEMP_FILE"
        else
            echo "Failed to decrypt the value for '$key'. Error: $decrypted_value"
            echo "Exiting with error code $exit_status."
            exit $exit_status
        fi
    else
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$ENV_FILE"

# Replace original file with decrypted file
mv "$TEMP_FILE" "$ENV_FILE"

# Clean up
rm -f "$DECODED_FILE"

echo "Your .env file has been updated with decrypted values."
