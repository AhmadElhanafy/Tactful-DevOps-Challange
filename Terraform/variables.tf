variable "project_name" {
  type        = string
  description = "Name prefix for all resources"
}

variable "location" {
  type        = string
  default     = "eastus"
}

variable "k8s_version" {
  type        = string
  default     = "1.29"
}

variable "node_count" {
  type        = number
  default     = 2
}

variable "node_vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "subscription_id" {
  type        = string
  default     = ""
}