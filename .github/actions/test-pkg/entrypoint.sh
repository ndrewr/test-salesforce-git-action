#!/bin/bash -l

AUTH_FILE_KEY=$1
TARGET_ALIAS=Prod
AUTH_URL="${TARGET_ALIAS,,}_auth_url.txt"
ENC_AUTH_URL="${AUTH_URL}.enc"

PKG_NAME="Test Package 1"

# Get the private url from environment variable, create required file for cmd
echo "Authenticating: Setting up Devhub Connection... ${TARGET_ALIAS}"

if test -f $ENC_AUTH_URL ; then
    openssl enc -d -aes-256-cbc -md md5 -in "$ENC_AUTH_URL" -out "$AUTH_URL" -k "$AUTH_FILE_KEY"
else
    echo "Required file missing: prod_auth_url.txt.enc! Exiting!"
    exit 1
fi

if test -f "$AUTH_URL" ; then
    # Authenticate to salesforce Prod org
    echo "Authenticating..."
    sfdx force:auth:sfdxurl:store -f "$AUTH_URL" -a "$TARGET_ALIAS" -d && rm "$AUTH_URL"

    echo "Creating first version of package ${PKG_NAME} ..."
    PKG_VER_ID=$(sfdx force:package:version:create --package "$PKG_NAME" --installationkeybypass --wait 15 \
    | grep login.salesforce.com \
    | sed -E 's/^.*(04t[[:alnum:]]*)$/\1/')

    if [ "$?" = "1" ]
    then
        echo "!!!Package test has failed!!!!"
        exit 1
    else
        echo "!!!Package test has apparently succeeded!!!!"
        echo "Successfully generated package with version ID: ${PKG_VER_ID}"
    fi
else
    echo "There was a problem generating auth_url file! Exiting!"
    exit 1
fi
