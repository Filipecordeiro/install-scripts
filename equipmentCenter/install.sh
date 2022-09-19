#!/bin/bash

set -e

## ======== PARAMETERS ========

read -p 'Infrastructure Name: ' infrastructure
read -p 'Agent Name: ' agent
read -p 'License: ' license
read -p 'Customer: ' customer
read -sp 'Customer Portal Token: ' portalToken
echo ${#portalToken} 
if [[ ${#portalToken} -lt 300 ]]
then
    echo "Error: Token is to short"
    exit
fi
partialToken="${portalToken:0: -4}"
echo "${partialToken//?/*}${portalToken: -4}"

read -p 'Environment Type (Testing/Production/Staging/Development) [Production]: ' environmentType
environmentType=${environmentType:-Production}
read -p 'Internet Network Name [internet]:' internetNetworkName
internetNetworkName=${internetNetworkName:-internet}
read -p 'Domain [localhost]:' domain
domain=${domain:-localhost}
read -p 'Agent Parameters: ' parameters

read -p 'Volumes base folder [opt/fec]: ' BASE_FOLDER
BASE_FOLDER=${BASE_FOLDER:-opt/fec}

## ======== CREATE INFRASTRUCTURE AND AGENT ========
echo; echo "Creating Infrastructure and Agent"
curl -fsSL https://raw.githubusercontent.com/criticalmanufacturing/install-scripts/main/ubuntu/install.bash | bash

## ======== DEPLOY AGENT ========
echo; echo "Deploying Agent"
curl -fsSL https://raw.githubusercontent.com/criticalmanufacturing/install-scripts/main/ubuntu/portal/initializeInfrastructure.bash | bash -s -- --agent "$agent" --license "$license" --customer "$customer" --infrastructure "$infrastructure" --domain "$domain" --environmentType "$environmentType" --internetNetworkName "$internetNetworkName" --portalToken "$portalToken" --parameters "$parameters"

## ======== CREATE VOLUMES FOLDERS ========
echo; echo "Creating volume folders"
mkdir -p $BASE_FOLDER/packages
mkdir -p $BASE_FOLDER/mssql
mkdir -p $BASE_FOLDER/documents
#mkdir -p $BASE_FOLDER/attachments
mkdir -p $BASE_FOLDER/logs
mkdir -p $BASE_FOLDER/multimedia
