#!/bin/bash -l

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
PKG_NAME=$(grep "Test Package 1" sfdx-project.json | tail -1 | sed -E 's/^.*"(04t[[:alnum:]]*)"$/\1/')

echo "Preparing to install package with id: ${PKG_NAME}"

sfdx force:package:install --package "PKG_NAME" --targetusername PackageTestOrg --noprompt --wait -1

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
