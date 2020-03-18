#!/bin/bash -l

AUTH_FILE_KEY=$1
TARGET_ALIAS=$2
AUTH_URL="${TARGET_ALIAS,,}_auth_url.txt"
ENC_AUTH_URL="${AUTH_URL}.enc"

# Get the private url from environment variable, create required file for cmd
echo "CI-Deploy: Setting up Devhub Connection... ${TARGET_ALIAS}"

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

if test -f "$AUTH_URL" ; then
    echo "Expected file seems to exist..."

    # Authenticate to salesforce Prod org
    echo "Authenticating..."
    sfdx force:auth:sfdxurl:store -f "$AUTH_URL" -a "$TARGET_ALIAS" && rm "$AUTH_URL"

    # Check deploy ID from prev successful step
    echo "Fetch Deploy ID..."
    DEPLOY_ID=$(sfdx force:mdapi:deploy:report -u "$TARGET_ALIAS" | grep "jobid" | sed -E 's/^jobid:[[:blank:]]*(.*)$/\1/')
    echo "Check deploy id... ${DEPLOY_ID}"

    # echo "Validating against production by simulating a deployment & running all tests..."
    sfdx force:mdapi:deploy -u Prod  -w -1 -q "$DEPLOY_ID"

    if [ "$?" = "1" ]
    then
        echo "!!!Deploy has failed!!!!"
        exit 1
    else
        echo "!!!Deploy has apparently succeeded!!!!"
    fi

    echo "CI Deploy action completed."
else
    echo "There was a problem generating auth_url file! Exiting!"
    exit 1
fi
