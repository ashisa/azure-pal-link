#!/bin/sh

if [ $# -lt 3 ]
then
    echo ERROR:
    echo insufficient parameters provided.
    echo syntax: './azure-pal-link.sh <MPN ID> <Parter/Solution Name> <Resource Group Name>'
    echo 
    exit 0
fi

MPN_ID=$1
SP_NAME=$(echo $2)-sp-for-pal
RES_GROUP_NAME=$3

echo fetching the tenant id...
TENANT_ID=$(az account show --query tenantId -o tsv)
echo

echo checking if the resource group \*\*$RES_GROUP_NAME\*\* exists and getting the scope...
RBAC_SCOPE=$(az group list --query "[?name=='$RES_GROUP_NAME'].id" -o tsv)
echo

if [ ! $RBAC_SCOPE ]
then
    echo ERROR:
    echo resoure group $RES_GROUP_NAME does not exist.
    echo please check the resource group name and re-run the script.
    echo
    exit 0
fi

echo creating service principal \*\*$SP_NAME\*\* and assign role on the scope...
SP_PASS=$(az ad sp create-for-rbac --name $SP_NAME --role Reader --scopes $RBAC_SCOPE --query password -o tsv)
echo

if [ ! $SP_PASS ]
then
    echo ERROR:
    echo could not create service principal.
    echo please see the error above and rectify.
    echo
    exit 0
fi

echo fetching the appId of the service principal \*\*$SP_NAME\*\*...
SP_ID=$(az ad sp list --display-name $SP_NAME --query [].appId -o tsv )
echo sevice principal ID: $SP_ID
echo

echo --------------------------------------------------------------------------
echo Note: Deleting $SP_NAME will remove the Partner Admin Link.
echo --------------------------------------------------------------------------
echo

echo waiting for 10 seconds for service principal ID propagation...
sleep 10
echo

echo authenticating using the service principal credentials...
count=0
status=65536
until [ $status -eq 0 ]
do
    az login --service-principal -u $SP_ID -p $SP_PASS --tenant $TENANT_ID
    status=$?
    count=$( expr $count + 1 )
    if [ $count -eq 5 ]
    then
        break
    fi
    if [ $status -eq 1 ]
    then
        echo will retry in 3 seconds \(5 retries\)...
        sleep 3
    fi
done

if [ $status -eq 0 ]
then
    echo linking partner ID \*\*$MPN_ID\*\*...
    az managementpartner create --partner-id $MPN_ID
    echo

    echo removing the app secret from environment variable...
    set SP_PASS=INVALID

    echo switching back to authenticated user...
    az login --identity
    echo
else
    echo ERROR:
    echo could not authenticate using the service principal.
    echo please review the errors above and consult support.
    echo
fi
