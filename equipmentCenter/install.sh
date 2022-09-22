#!/bin/bash

set -e

## ======== PARAMETERS ========

read -p 'Infrastructure Name: ' infrastructure </dev/tty
read -p 'Agent Name: ' agent </dev/tty
read -p 'License: ' license </dev/tty
read -p 'Customer: ' customer </dev/tty
read -sp 'Customer Portal Token: ' portalToken </dev/tty
if [[ ${#portalToken} -lt 300 ]]
then
    echo "Error: Token is to short (${#portalToken})"
    exit
fi
partialToken="${portalToken:0: -4}"
echo "${partialToken//?/*}${portalToken: -4}"

read -p 'Environment Type (Testing/Production/Staging/Development) [Production]: ' environmentType </dev/tty
environmentType=${environmentType:-Production}
read -p 'Internet Network Name [internet]:' internetNetworkName </dev/tty
internetNetworkName=${internetNetworkName:-internet}
read -p 'Domain [localhost]:' domain </dev/tty
domain=${domain:-localhost}
read -p 'Agent Parameters: ' parameters </dev/tty

read -p 'Volumes base folder [opt/fec]: ' BASE_FOLDER </dev/tty
BASE_FOLDER=${BASE_FOLDER:-opt/fec}

if [ -z "$REPOSITORY" ]
then
    read -p 'Scripts repository [https://raw.githubusercontent.com/criticalmanufacturing/install-scripts/main]: ' REPOSITORY </dev/tty
    REPOSITORY=${REPOSITORY:-"https://raw.githubusercontent.com/criticalmanufacturing/install-scripts/main"}
fi

if [ -z "$REPOSITORY_USER" ]
then
    read -p 'Scripts repository user: ' REPOSITORY_USER </dev/tty
fi

if [ -z "$REPOSITORY_PASSWORD" ]
then
    read -sp 'Scripts repository password: ' REPOSITORY_PASSWORD </dev/tty
fi

## ======== CREATE INFRASTRUCTURE AND AGENT ========
echo; echo "Creating Infrastructure and Agent"
curl -fsSL -u $REPOSITORY_USER:$REPOSITORY_PASSWORD $REPOSITORY/ubuntu/install.bash | bash

## ======== DEPLOY AGENT ========
echo; echo "Deploying Agent"
curl -fsSL -u $REPOSITORY_USER:$REPOSITORY_PASSWORD $REPOSITORY/ubuntu/portal/initializeInfrastructure.bash | bash -s -- --agent "$agent" --license "$license" --customer "$customer" --infrastructure "$infrastructure" --domain "$domain" --environmentType "$environmentType" --internetNetworkName "$internetNetworkName" --portalToken "$portalToken" --parameters "$parameters"

## ======== CREATE VOLUMES FOLDERS ========
echo; echo "Creating volume folders"
mkdir -p $BASE_FOLDER/packages
mkdir -p $BASE_FOLDER/mssql
mkdir -p $BASE_FOLDER/documents
#mkdir -p $BASE_FOLDER/attachments
mkdir -p $BASE_FOLDER/logs
mkdir -p $BASE_FOLDER/multimedia
