# Automate Parter Admin Link with *azure-pal-link*

Partner Admin Link process allows Azure partners to link their Microsoft Partner Network (MPN) ID with the Azure resources that they manage and maintain in the customer subscriptions.

The *azure-pal-link* is a script that can automatically link an MPN ID with resources in an Azure subscription. This script can be executed in the [Azure Cloud Shell](https://azure.microsoft.com/en-in/features/cloud-shell/#overview) quickly.

[PAL enables Microsoft to identify and recognize partners who drive Azure customer success. Microsoft can attribute influence and Azure consumed revenue to your organization based on the account's permissions (Azure role) and scope (subscription, resource group, resource).](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/link-partner-id)

To do this, access to resources in customer subscription is the primary requirement. The access can be provided using any one of the following -
1. Guest user access - Your customer can invite users from partner tenant
2. Directory account - The customer can create user accounts in their tenant and grant them access to manage the resources
3. Service Principal - If the above scenarios are not possible, a [Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals?WT.mc_id=devops-10986-petender#service-principal-object) in the customer tenant can also be used
4. Azure Lighthouse - Your customer can delegate a subscription (or resource group) so that your users can work on it from within your tenant. See more on [Azure Lighthouse](https://docs.microsoft.com/en-us/azure/lighthouse/overview)

The MPN ID of the partner is a required input as well. This ID can retrieved from [Microsoft Partner Network](https://docs.microsoft.com/en-us/azure/lighthouse/overview) portal from the parter profile.

## How does it work?

For simplicity, the *azure-pal-link* script creates a service principal with Reader access to a resource group in the customer subscription. A user in the customer tenant with Owner access is required to execute this script. Following are the steps that it performs -
1. Create Service Principal in customer tenant
2. Create a "Reader" role assignment under the resource group scope that was provided on the command line
3. Use the Service Principal credentials to create a session
4. Link the partner ID

## Executing the script

Start a BASH shell at [Azure Cloud Shell](https://shell.azure.com) and download the script -
```
cd clouddrive
wget --no-cache https://raw.githubusercontent.com/ashisa/azure-pal-link/main/azure-pal-link.sh -O ./azure-pal-link.sh
```

You are now ready to run the script -
```
./azure-pal-link.sh <MPN ID> <Partner/Solution Name> <Resource Group Name>
```

Descriptio of parameters -
- MPN ID - MPN ID of the partner
- Partner/Solution Name - The name of the partner or the solution. This will be used to create a service principal
- Resource Group Name - The name of the resource group in customer subscription where the Azure resources reside

Keep an eye on the script execution. When the script finishes, you will all be set with Partner Admin Link process.

Open issue in this repo, if you run in to any issues. Share relevant information for debugging.