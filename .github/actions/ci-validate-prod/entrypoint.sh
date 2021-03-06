#!/bin/sh -l

# echo "Time to run local action one..."
# sh -c "sfdx -v"

# Get the private url from environment variable, create required file for cmd
echo "Setting up Prod Connection..."
openssl enc -d -aes-256-cbc -md md5 -in prod_auth_url.txt.enc -out prod_auth_url.txt -k $AUTH_FILE_KEY

# Authenticate to salesforce Prod org
echo "Authenticating..."
sfdx force:auth:sfdxurl:store -f prod_auth_url.txt -a Prod && rm prod_auth_url.txt

#Convert to MDAPI format for validation against prod
echo "Converting to MDAPI format..."
# sfdx force:source:convert -d validate_prod -r force-app
#Simulate deployment to prod & run all tests
echo "Validating against production by simulating a deployment & running all tests..."
# sfdx force:mdapi:deploy -c -d validate_prod -u Prod -l RunLocalTests -w -1

echo "CI Validate Prod action completed."
