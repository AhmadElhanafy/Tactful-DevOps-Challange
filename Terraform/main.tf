terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "local" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

#
# RESOURCE GROUP
#
resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-${terraform.workspace}-rg"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "tactfulvoting${terraform.workspace}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

#
# VNET
#
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#
# AKS CLUSTER
#
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.project_name}-${terraform.workspace}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.project_name}-dns"

  kubernetes_version = var.k8s_version

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

#
# OUTPUT kubeconfig
#
resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig"
  content  = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}
