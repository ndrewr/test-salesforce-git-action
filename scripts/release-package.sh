#!/bin/bash -l

# 2GP Workflow, when should we trigger the script to create a promoted version

# Create package version, install in scratch org to test manually
# All looks fine, move to promote version for release ...
# Can we trigger version promotion based on branch merge? DEV? MASTER?
# If so, how do we specify the package Alias or ID?
# Can we adopt a convention to include in the PR / merge-commit message?
# Or hard-code specify the package alias name in the scripting? UPDATE: after testing, looks like alias has to be SPECIFIC version alias and not generic package name/alias
# Can we grep the sfdx-project.json file for the Project name, then grab the last instance (i.e. most recently created version?)


# PKG_ALIAS="Expense Manager@1.3.0-7"

# authenticate

# need package alias or ID
echo "Create package version for promotion..."
PKG_VER_ID=$(sfdx force:package:version:create --package "Test Package 1" --installationkeybypass --wait 15 \
| grep login.salesforce.com \
| sed -E 's/^.*(04t[[:alnum:]]*)$/\1/')


# Promote package
echo "Done! Promote this package for release! Package ID: ${PKG_VER_ID}"
# -p, --package=package : (required) ID (starts with 04t) or alias of the package version to promote
sfdx force:package:version:promote --package "$PKG_VER_ID" --noprompt

echo "Package version has been promoted!"

# Sample output
# Successfully promoted the package version, ID: 04tB0000000719qIAA to released.

# View package details
sfdx force:package:version:report --package "$PKG_VER_ID"

# Check if "PackageTestOrg" already exists, delete if it does
# Requires that a Package version ID was successfully generated in prior step
# if [ -z "$PACKAGE_VER_ID" ]; then
#     echo "No package version to install! Exiting..."
#     exit 1
# fi

# echo "Checking package name ... ${PKG_NAME}"

# echo "Install package to temporary scratch org for testing with version ID: ${PACKAGE_VER_ID} ... "

if sfdx force:org:list | grep 'PackageTestOrg'; then
    echo "Deleting pre-existing test scratch org ..."
    sfdx force:org:delete -u PackageTestOrg -p
else
    echo "!!!Scratch org does not exist!!!!"
fi

echo "Creating a new scratch org for testing..."

# Generate a fresh scratch org to install the package
sfdx force:org:create --definitionfile config/project-scratch-def.json --setalias PackageTestOrg

# Install the package and open the new scratch org for testing
# sfdx force:package:install --package "$PACKAGE_VER_ID" --targetusername PackageTestOrg
# PKG_VER_ID=$(grep "Test Package 1" sfdx-project.json | tail -1 | sed -E 's/^.*"(04t[[:alnum:]]*)"$/\1/')

echo "Preparing to install PROMOTED package with id: ${PKG_VER_ID}"

sfdx force:package:install --package "$PKG_VER_ID" --targetusername PackageTestOrg --noprompt --wait -1

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Problem installing package!"
	exit
else
    echo "Package install successful!"
fi

unset PACKAGE_VER_ID

echo ""
echo "Opening scratch org for testing, may the Flow be with you!"
echo ""
sleep 3
sfdx force:org:open --targetusername PackageTestOrg

exit
