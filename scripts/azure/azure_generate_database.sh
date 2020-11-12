#!/bin/bash
# # Set variables
# subscriptionID="${AZURE_DEFAULT_SUBSCRIPTION}"
# resourceGroupName="${AZURE_DEFAULT_RESOURCE_GROUP}-keycloak"
# location="${AZURE_DEFAULT_LOCATION}"
# adminLogin="azadmin"
# password="PWD27!"+`openssl rand -base64 18`
# serverName="sqldb-ravimo-keycloak-test"
# databaseName="keycloak"
# drLocation="${location}"
# drServerName="mysqlsecondary-${RANDOM}"
# failoverGroupName="failovergrouptutorial-$RANDOM"

# # The ip address range that you want to allow to access your DB.
# # Leaving at 0.0.0.0 will prevent outside-of-azure connections to your DB
# startip=0.0.0.0
# endip=0.0.0.0

# # Connect to Azure
# az login

# echo "Setting default subscription to ${subscriptionID}"
# # Set the subscription context for the Azure account
# az account set -s "${subscriptionID}"

# # Create a resource group
# echo "Creating resource group ${resourceGroupName}"
# az group create \
#     --name "${resourceGroupName}" \
#     --location "${location}" \
#     --tags creator[=patricio] subscription[="${AZURE_DEFAULT_SUBSCRIPTION}"]

# echo "Creating sql server ${serverName}"
# # Create a logical server in the resource group
# echo "Creating primary logical server..."
# az sql server create \
#     --name "${serverName}" \
#     --resource-group "${resourceGroupName}" \
#     --location "${location}"  \
#     --admin-user "${adminLogin}" \
#     --admin-password "${password}"

# # Configure a firewall rule for the server
# # echo "Configuring firewall..."
# # az sql server firewall-rule create \
# #     --resource-group "${resourceGroupName}" \
# #     --server "${serverName}" \
# #     -n AllowYourIp \
# #     --start-ip-address "${startip}" \
# #     --end-ip-address "${endip}"

# # Create a gen5 1vCore database in the server 
# echo "Creating a gen5 2 vCore database..."
# az sql db create \
#     --resource-group "${resourceGroupName}" \
#     --server "${serverName}" \
#     --name "${databaseName}" \
#     --sample-name AdventureWorksLT \
#     --edition GeneralPurpose \
#     --family Gen5 \
#     --capacity 2