#!/bin/bash -l

# Get the private url from environment variable, create required file for cmd
echo "Setting up Prod Connection..."

# export TEMPY="${TEMPY^^}plus"
AUTH_FILE_KEY=$1
TARGET_ALIAS=$2
AUTH_URL="${TARGET_ALIAS,,}_auth_url.txt"
ENC_AUTH_URL="${AUTH_URL}.enc"

echo "Target org alias... ${TARGET_ALIAS}"

# For a remote action that tries to get value from passed env
# echo -n "$AUTH_URL_ENC" > prod_auth_url.txt.enc
# printf "%s" "$AUTH_URL_ENC" > prod_auth_url.txt.enc

if test -f $ENC_AUTH_URL ; then
    # openssl enc -d -aes-256-cbc -md md5 -in prod_auth_url.txt.enc -out prod_auth_url.txt -k $1
    openssl enc -d -aes-256-cbc -md md5 -in "$ENC_AUTH_URL" -out "$AUTH_URL" -k "$AUTH_FILE_KEY"

else
    echo "Required file missing: prod_auth_url.txt.enc! Exiting!"
    exit 1
fi

if test -f prod_auth_url.txt ; then
    echo "Expected file seems to exist..."

    # Authenticate to salesforce Prod org
    echo "Authenticating..."
    sfdx force:auth:sfdxurl:store -f prod_auth_url.txt -a Prod && rm prod_auth_url.txt
    #Convert to MDAPI format for validation against prod
    echo "Converting to MDAPI format..."
    sfdx force:source:convert -d validate_prod -r force-app
    #Simulate deployment to prod & run all tests
    echo "Validating against production by simulating a deployment & running all tests..."
    sfdx force:mdapi:deploy -c -d validate_prod -u Prod -l RunLocalTests -w -1

    if [ "$?" = "1" ]
    then
        echo "!!!Deploy has failed!!!!"
        exit 1
    else
        echo "!!!Deploy has apparently succeeded!!!!"
    fi

    echo "CI Validate Prod action completed."
else
    echo "There was a problem generating auth_url file! Exiting!"
    exit 1
fi
