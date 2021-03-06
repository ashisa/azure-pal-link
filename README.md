# Automate Parter Admin Link with *azure-pal-link*

Partner Admin Link process allows Azure partners to link their Microsoft Partner Network (MPN) ID with the Azure resources that they manage and maintain in the customer subscriptions.

The *azure-pal-link* is a script that can automatically link an MPN ID with resources in an Azure subscription. This script can be executed in the [Azure Cloud Shell](https://azure.microsoft.com/en-in/features/cloud-shell/#overview) quickly.

[PAL enables Microsoft to identify and recognize partners who drive Azure customer success. Microsoft can attribute influence and Azure consumed revenue to your organization based on the account's permissions (Azure role) and scope (subscription, resource group, resource).](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/link-partner-id)

To do this, access to resources in customer subscription is the primary requirement. The access can be provided using any one of the following -
1. Guest user access - Your customer can invite users from partner tenant
2. Directory account - The customer can create user accounts in their tenant and grant them access to manage the resources
3. Service Principal - If the above scenarios are not possible, a [Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals?WT.mc_id=devops-10986-petender#service-principal-object) in the customer tenant can also be used
4. Azure Lighthouse - Your customer can delegate a subscription (or resource group) so that your users can work on it from within your tenant. See more on [Azure Lighthouse](https://docs.microsoft.com/en-us/azure/lighthouse/overview)

The MPN ID of the partner is a required input as well. This ID can be retrieved from [Microsoft Partner Network](https://docs.microsoft.com/en-us/azure/lighthouse/overview) portal from the parter profile.

## How does it work?

For simplicity, the *azure-pal-link* script creates a service principal with Reader access to a resource group in the customer subscription. A user in the customer tenant with Owner access is required to execute this script. Following are the steps that it performs -
1. Create Service Principal in customer tenant
2. Get the scopes for the resource groups provided on the command line
3. Create a "Reader" role assignment for the resource group scopes
4. Use the Service Principal credentials to create a session
5. Link the partner ID

## Executing the script

Start a BASH shell at [Azure Cloud Shell](https://shell.azure.com) and download the script -
```
cd clouddrive
wget --no-cache https://raw.githubusercontent.com/ashisa/azure-pal-link/main/azure-pal-link.sh -O ./azure-pal-link.sh
```

You are now ready to run the script -
```
./azure-pal-link.sh <MPN ID> <Partner/Solution Name> <Resource Group Names>
```

Description of parameters -
1. MPN ID - MPN ID of the partner
2. Partner/Solution Name - The name of the partner or the solution. This will be used to create a service principal
3. Resource Group Names - The names of the resource groups space-separated in customer subscription where the Azure resources reside

Keep an eye on the script execution. When the script finishes, you will be all set with Partner Admin Link process.

If you run in to any issues, please open an issue in this repo. Share relevant information for debugging.

## Security practices employed

The script uses the logged in user's security context. Following security aspects have been considered during the execution -
- While creating the service principal, it relies on the AZ CLI's built-in functionality of generating a random secret. This secret is stored in the SP_PASS variable temporarily and is discarded immediately after the MPN ID has been linked. You will have to regenerate a new secret if you want to reuse the service principal for any other purposes.
- The role assignment for the service principal is set to "Reader" which allows the service principal only read access on the resource group scope - the service principal credentials cannot be used to make any changes to any resource
- At the end of the execution, the script changes AZ CLI authentication context back to the logged user from the service principal.
  