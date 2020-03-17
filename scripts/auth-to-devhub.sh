#!/bin/bash -l

AUTH_FILE_KEY=$1
TARGET_ALIAS=Prod
AUTH_URL="${TARGET_ALIAS,,}_auth_url.txt"
ENC_AUTH_URL="${AUTH_URL}.enc"

# Get the private url from environment variable, create required file for cmd
echo "Authenticating: Setting up Devhub Connection... ${TARGET_ALIAS}"

if test -f $ENC_AUTH_URL ; then
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

    if [ "$?" = "1" ]
    then
        echo "" && echo "ERROR: Problem authenticating to devhub!"
        exit
    else
        echo "Authentication successful!"
    fi

else
    echo "Issue creating the auth url file!!!"
    exit
fi
