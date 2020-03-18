#!/bin/bash -l

# This script generates a new package followed by its first version
# Package versions are required because they are what actually get installed
# Prior to running this script and generating the package, it is expected the developer:
# Verified that all package components are in the project directory where you want to create the package

set -e

# Find out the package name and the package directory; Create these if it does not exist
read -p "Enter package name? " PKG_NAME

# read -p "Enter directory path to this package (relative to project root): " PKG_PATH

PKG_PATH=$(echo "$PKG_NAME"\
    | sed -E 's/[[:blank:]]+([a-z0-9])/\U\1/gi'\
    | sed -E 's/_([A-Z0-9])/\U\1/gi'\
    | sed -E 's/-([A-Z0-9])/\U\1/gi'\
    | sed -E 's/^([A-Z0-9])/\l\1/')

read -p "Is this the correct package path: ${PKG_PATH}? y/n " ACCEPT_PATH

# Ensure package folder name and existence
if [[ "$ACCEPT_PATH" != 'y' ]] ; then
    read -p "Enter desired package path: " PKG_PATH
fi

if [[ ! -d "$PKG_PATH" ]]; then
    echo "Package directory does not exist!"
    exit 1
fi

# Check if package has alrady been created
if grep "\"$PKG_NAME\"," sfdx-project.json; then
    echo 'This package has already been created! Moving on to versioning ... '
else
    # Create the package's first version so it can be installed
    echo "Creating the package ${PKG_NAME}."
    read  -p "Is this a Managed package (and Namespace is prepared)? y/n " PKG_TYPE
    test "$PKG_TYPE" == 'y' && PKG_TYPE='Managed' || PKG_TYPE='Unlocked'
    sfdx force:package:create --name "$PKG_NAME" --packagetype "$PKG_TYPE" --path "$PKG_PATH"
fi

#
# A step for updating the newly-generated package's configuration fields can go here (see package.json)
#

# Optionally skip validation for rapid development; This will become mandatory before package promotion however
read -p "Temporarily skip validation in package version creation? " SKIP_VALIDATION

if [ "$SKIP_VALIDATION" == 'y' ]; then
    echo "Creating first version of package ${PKG_NAME} ... skipping validation ..."
    PACKAGE_VER_ID=$(sfdx force:package:version:create --package "$PKG_NAME" --installationkeybypass --wait 15 --skipvalidation \
    | grep login.salesforce.com \
    | sed -E 's/^.*(04t[[:alnum:]]*)$/\1/')
else
    echo "Creating first version of package ${PKG_NAME} ..."
    PACKAGE_VER_ID=$(sfdx force:package:version:create --package "$PKG_NAME" --installationkeybypass --wait 15 \
    | grep login.salesforce.com \
    | sed -E 's/^.*(04t[[:alnum:]]*)$/\1/')
fi

echo "Successfully generated package with version ID: ${PACKAGE_VER_ID}"

# Sample Result
# === Package Version Create Request
# NAME                            VALUE
# ─────────────────────────────   ────────────────────
# Version Create Request Id       08cB00000004CBxIAM
# Status                          InProgress
# Package Id                      0HoB00000004C9hKAE
# Package Version Id              05iB0000000CaaNIAS
# Subscriber Package Version Id   04tB0000000NOimIAG
# Tag                             git commit id 08dcfsdf
# Branch
# CreatedDate                     2018-05-08 09:48
# Installation URL
# https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000NOimIAG

# echo "Install package to temporary scratch org for testing..."

# Optionally install this new package version into a test scratch org for immediate testing
while true; do
    read -p "Continue with test org installation? y/n " TEST_INSTALL
    case "$TEST_INSTALL" in
        [Yy]* ) source scripts/test-package.sh;;
        [Nn]* ) break;;
        * ) echo "y/n.";;
    esac
done
