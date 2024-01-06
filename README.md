
# TestNodeApp
![image](https://github.com/zdbrig/secure-run/assets/934740/55970c04-5594-4350-9e6b-8b4090863082)

This is a simple Node.js application that demonstrates how to securely manage environment variables for development purposes.

## Overview

The project includes scripts for encrypting your `.env` file and securely setting up your environment variables at runtime without ever writing them to disk.

## Scripts

- `encrypt_env.sh`: A script to encrypt your `.env` file using a secure password.
- `start_secure_app.sh`: A script to decrypt your `.env.enc` file in memory and start the Node.js application with the environment variables set.

## Usage

1. **Encrypting the Environment File**
   - Run `./encrypt_env.sh` and follow the prompts to encrypt your `.env` file.
   - This will create a `.env.enc` file which is the encrypted version of your `.env`.

2. **Running the Application Securely**
   - Start your application using `./start_secure_app.sh`.
   - This script will ask for the decryption password, decrypt the environment variables in memory, and start the application.

## Important Notes

- Do not push `.env` or `.env.enc` to any public repositories. These should be kept private and secure.
- Always ensure your scripts and application are running in a secure and trusted environment.

## Requirements

- Node.js
- OpenSSL
- ts-node (for running TypeScript files)

## Contributing

Feel free to fork this project and customize it as per your needs.

## License

Specify your license here or indicate if the project is open for public use.
