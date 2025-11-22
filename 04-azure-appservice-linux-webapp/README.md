# Lab 04: Azure App Service (Linux Web App)

## Overview

In this lab, you will deploy an Azure App Service Plan and a Linux Web App using Terraform. This is a foundational exercise for hosting web applications on Azure.

## Learning Objectives

- Deploy an Azure Resource Group
- Create an App Service Plan with Linux OS
- Deploy a Linux Web App with runtime stack configuration
- Configure basic application settings
- Understand outputs and how to access your deployed web app

## Prerequisites

- Azure subscription
- Azure CLI installed and authenticated
- Terraform installed (version >= 1.0)
- Azure Storage Account for Terraform backend (configured separately)

## Lab Structure

```
04-azure-appservice-linux-webapp/
├── providers.tf              # Provider and backend configuration
├── variables.tf              # Variable definitions
├── main.tf                   # Main resource definitions
├── outputs.tf                # Output definitions
├── terraform.tfvars.example  # Example variable values
└── README.md                 # This file
```

## Step 1: Prepare Your Configuration

1. Copy the example variables file to create your own:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your preferred values:

```hcl
project_name            = "tf-appservice-demo"
location                = "australiasoutheast"
environment             = "dev"
appservice_plan_sku     = "B1"
appservice_runtime_stack = "NODE:20-lts"
```

### Available Runtime Stacks

Choose one of the following for `appservice_runtime_stack`:

- **Node.js**: `NODE:20-lts`, `NODE:18-lts`
- **.NET Core**: `DOTNETCORE:8.0`, `DOTNETCORE:7.0`
- **Python**: `PYTHON:3.11`, `PYTHON:3.10`
- **Java**: `JAVA:17-java17`, `JAVA:11-java11`

### Available SKUs

Common SKUs for `appservice_plan_sku`:

- **Free/Shared**: `F1` (Free), `D1` (Shared)
- **Basic**: `B1`, `B2`, `B3`
- **Standard**: `S1`, `S2`, `S3`
- **Premium V2**: `P1v2`, `P2v2`, `P3v2`
- **Premium V3**: `P1v3`, `P2v3`, `P3v3`

## Step 2: Configure Backend

Before initializing Terraform, ensure you have configured your Azure backend. You'll need to set environment variables or use a backend configuration file.

Example backend configuration (create a file named `backend.conf`):

```hcl
resource_group_name  = "rg-terraform-state"
storage_account_name = "tfstatexxxxxxx"
container_name       = "tfstate"
```

## Step 3: Initialize Terraform

Initialize Terraform with the backend configuration:

```bash
terraform init -backend-config=backend.conf
```

This will:
- Download the Azure provider
- Configure the remote backend
- Create the state file: `appservice-dev.tfstate` (based on your environment variable)

## Step 4: Plan the Deployment

Review what Terraform will create:

```bash
terraform plan
```

You should see:
- 1 Resource Group
- 1 App Service Plan (Linux)
- 1 Linux Web App

## Step 5: Apply the Configuration

Deploy the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## Step 6: Verify Your Deployment

After a successful apply, Terraform will output:

```
Outputs:

app_service_plan_id = "/subscriptions/xxxxx/..."
resource_group_name = "rg-tf-appservice-demo-dev"
web_app_default_hostname = "app-tf-appservice-demo-dev.azurewebsites.net"
web_app_name = "app-tf-appservice-demo-dev"
web_app_url = "https://app-tf-appservice-demo-dev.azurewebsites.net"
```

### Access Your Web App

1. Copy the `web_app_url` from the output
2. Open it in your browser
3. You should see a default Azure App Service page (since no application code has been deployed yet)

### Verify in Azure Portal

1. Navigate to the Azure Portal
2. Search for your resource group (e.g., `rg-tf-appservice-demo-dev`)
3. You should see:
   - App Service Plan: `asp-tf-appservice-demo-dev`
   - App Service: `app-tf-appservice-demo-dev`

## Step 7: Check Application Settings

In the Azure Portal:

1. Navigate to your App Service
2. Go to **Configuration** → **Application settings**
3. You should see the setting: `APP_MESSAGE = "Hello from Terraform"`

## Optional Exercises

### Exercise 1: Modify Application Settings

1. Edit `main.tf` and add a new app setting:

```hcl
app_settings = {
  "APP_MESSAGE"              = "Hello from Terraform - Updated!"
  "CUSTOM_SETTING"           = "MyCustomValue"
  "WEBSITE_NODE_DEFAULT_VERSION" = "~20"
}
```

2. Apply the changes:

```bash
terraform apply
```

3. Check the Azure Portal to verify the new setting appears

### Exercise 2: Change Runtime Stack

1. Edit `terraform.tfvars` and change the runtime:

```hcl
appservice_runtime_stack = "PYTHON:3.11"
```

2. Plan and apply:

```bash
terraform plan
terraform apply
```

3. Verify the runtime stack change in the Azure Portal under **Configuration** → **General settings**

### Exercise 3: Scale Up the App Service Plan

1. Edit `terraform.tfvars` and change the SKU:

```hcl
appservice_plan_sku = "S1"
```

2. Apply the changes and observe the plan change

### Exercise 4: Deploy Sample Code (Advanced)

While deploying application code is outside this basic lab, here's where you would deploy it:

**Option 1: Using Azure CLI**
```bash
# For Node.js example
az webapp deployment source config-zip \
  --resource-group rg-tf-appservice-demo-dev \
  --name app-tf-appservice-demo-dev \
  --src app.zip
```

**Option 2: Using GitHub Actions** (configure in Azure Portal → Deployment Center)

**Option 3: Using Visual Studio Code** (Azure App Service extension)

## Resources Created

This lab creates the following Azure resources:

| Resource Type | Resource Name | Purpose |
|--------------|---------------|---------|
| Resource Group | `rg-{project_name}-{environment}` | Container for all resources |
| App Service Plan | `asp-{project_name}-{environment}` | Defines compute resources for web app |
| Linux Web App | `app-{project_name}-{environment}` | The web application host |

## Understanding the Configuration

### main.tf Structure

1. **Resource Group**: Container for all App Service resources
2. **App Service Plan**: Defines:
   - OS Type: Linux
   - SKU: Pricing tier and compute resources
   - Location: Azure region

3. **Linux Web App**: Defines:
   - Service Plan association
   - Runtime stack (Node.js, .NET, Python, Java)
   - Application settings
   - Site configuration

### Application Stack Configuration

The `application_stack` block in `main.tf` uses conditional logic to parse the runtime stack variable:

```hcl
application_stack {
  node_version = length(regexall("^NODE:", var.appservice_runtime_stack)) > 0 ? split(":", var.appservice_runtime_stack)[1] : null
  # Similar logic for dotnet_version, python_version, java_version
}
```

This allows you to specify the runtime in a simple format like `NODE:20-lts`.

## Cleanup

To destroy all resources created in this lab:

```bash
terraform destroy
```

Type `yes` when prompted. This will remove:
- Linux Web App
- App Service Plan
- Resource Group

## Troubleshooting

### Issue: App Service name already exists

**Error**: `Web App names must be globally unique`

**Solution**: Change the `project_name` in `terraform.tfvars` to something unique

### Issue: Backend not configured

**Error**: `Backend initialization required`

**Solution**: Ensure you've run `terraform init` with the correct backend configuration

### Issue: Invalid SKU for Linux

**Error**: `SKU not supported for Linux`

**Solution**: Ensure you're using a Linux-compatible SKU (F1, B1, S1, P1v2, etc.)

### Issue: Runtime stack not applying

**Solution**: Verify the format matches one of the supported patterns (e.g., `NODE:20-lts`, not just `node` or `20`)

## Additional Resources

- [Azure App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [Terraform Azure Provider - Linux Web App](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app)
- [App Service Pricing](https://azure.microsoft.com/en-us/pricing/details/app-service/linux/)
- [Supported Runtime Stacks](https://learn.microsoft.com/en-us/azure/app-service/overview#built-in-languages-and-frameworks)

## Next Steps

After completing this lab, consider:

1. Deploying a sample application to your web app
2. Configuring custom domains and SSL certificates
3. Setting up deployment slots for blue-green deployments
4. Implementing Application Insights for monitoring
5. Configuring authentication and authorization
6. Setting up CI/CD pipelines with GitHub Actions or Azure DevOps

## Summary

In this lab, you learned how to:
- ✅ Define Azure App Service resources in Terraform
- ✅ Configure Linux-based App Service Plans
- ✅ Deploy a Linux Web App with runtime configuration
- ✅ Set application settings via Terraform
- ✅ Use Terraform outputs to access deployment information
- ✅ Modify and update app configurations

This foundational knowledge prepares you for more advanced App Service scenarios including multi-region deployments, custom containers, and production-ready configurations.
