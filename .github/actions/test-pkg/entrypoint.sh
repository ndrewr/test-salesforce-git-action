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
    # PKG_VER_ID=$(sfdx force:package:version:create --package "$PKG_NAME" --installationkeybypass --codecoverage --wait 15 \
    # | grep login.salesforce.com \
    # | sed -E 's/^.*(04t[[:alnum:]]*)$/\1/')


    sfdx force:package:version:create --package "$PKG_NAME" --installationkeybypass --codecoverage --wait 15

    if [ "$?" = "1" ]; then
        echo "!!!Package test has failed!!!!"
        exit 1
    else
        echo "!!!Package test has apparently succeeded!!!?!"
        # echo "Successfully generated package with version ID: ${PKG_VER_ID}"
    fi

    PKG_VER_ID=$(grep "Test Package 1" sfdx-project.json | tail -1 | sed -E 's/^.*"(04t[[:alnum:]]*)"$/\1/')


    echo "Creating a test scratch org and installing package..."

    if sfdx force:org:list | grep 'PackageTestOrg'; then
        echo "Deleting pre-existing test scratch org ..."
        sfdx force:org:delete -u PackageTestOrg -p
    else
        echo "!!!Scratch org does not exist!!!!"
    fi

    sfdx force:org:create --definitionfile config/project-scratch-def.json --setalias PackageTestOrg

    echo "Preparing to install package with id: ${PKG_VER_ID}"

    sfdx force:package:install --package "$PKG_VER_ID" --targetusername PackageTestOrg --noprompt --wait -1

    if [ "$?" = "1" ]
    then
        echo "" && echo "ERROR: Problem installing package!"
        exit
    else
        echo "Package install successful!"
    fi


else
    echo "There was a problem generating auth_url file! Exiting!"
    exit 1
fi
