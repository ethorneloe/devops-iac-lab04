# Resource Group for App Service resources
resource "azurerm_resource_group" "rg_app" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# App Service Plan (Linux)
resource "azurerm_service_plan" "plan_app" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location
  os_type             = "Linux"
  sku_name            = var.appservice_plan_sku

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Linux Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = "app-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_service_plan.plan_app.location
  service_plan_id     = azurerm_service_plan.plan_app.id

  site_config {
    always_on = false

    application_stack {
      # Parse the runtime stack variable
      # Examples: "NODE:20-lts", "DOTNETCORE:8.0", "PYTHON:3.11", "JAVA:17-java17"

      # Node.js
      node_version = length(regexall("^NODE:", var.appservice_runtime_stack)) > 0 ? split(":", var.appservice_runtime_stack)[1] : null

      # .NET Core
      dotnet_version = length(regexall("^DOTNETCORE:", var.appservice_runtime_stack)) > 0 ? split(":", var.appservice_runtime_stack)[1] : null

      # Python
      python_version = length(regexall("^PYTHON:", var.appservice_runtime_stack)) > 0 ? split(":", var.appservice_runtime_stack)[1] : null

      # Java
      java_version = length(regexall("^JAVA:", var.appservice_runtime_stack)) > 0 ? split(":", var.appservice_runtime_stack)[1] : null
    }
  }

  app_settings = {
    "APP_MESSAGE"              = "Hello from Terraform"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~20"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
