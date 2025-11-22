# Common variables
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

# App Service specific variables
variable "appservice_plan_sku" {
  description = "SKU for the App Service Plan (e.g., B1, B2, S1, P1v2)"
  type        = string
  default     = "B1"
}

variable "appservice_runtime_stack" {
  description = "Runtime stack for the Linux Web App (e.g., 'DOTNETCORE:8.0', 'NODE:20-lts', 'PYTHON:3.11', 'JAVA:17-java17')"
  type        = string
}
