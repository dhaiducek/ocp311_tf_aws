variable "cluster_user_id" {
  type        = string
  description = "User ID for tagging AWS resources"
}

variable "cluster_name" {
  type        = string
  description = "Name of cluster for tagging AWS resources"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID"
}

variable aws_secret_access_key {
  type        = string
  description = "AWS Secret Access Key"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "aws_base_dns_domain" {
  type        = string
  description = "Base public DNS domain under which to create resources"
  default     = ""
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "openshift_deployment_type" {
  type        = string
  description = "Default to Community/OKD. For Enterprise specify 'openshift-enterprise' and provide your subscription credentials"
  default     = "origin"
}

variable "skip_install" {
  type        = bool
  description = "Specify whether to skip installing OCP and only set up the infrastructure"
  default     = false
}

variable "rh_subscription_username" {
  description = "Red Hat Network login username for registration system of the OpenShift Container Platform cluster"
}

variable "rh_subscription_password" {
  description = "Red Hat Network login password for registration system of the OpenShift Container Platform cluster"
}

variable "rh_subscription_pool_id" {
  description = "Red Hat subscription pool id for OpenShift Container Platform"
}

variable "ocp_user" {
  type        = string
  description = "User for logging in to OCP via htpasswd"
  default     = "acmtest"
}

variable "ocp_pass" {
  type        = string
  description = "Password for logging in to OCP via htpasswd"
  default     = "Test4ACM"
}

data "aws_availability_zones" "zones" {}

variable vpc_cidr {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable public_subnet_cidr {
  type        = string
  description = "Public Subnet CIDR"
  default     = "10.0.0.0/20"
}

variable private_subnet_cidr {
  type        = string
  description = "Private Subnet CIDR"
  default     = "10.0.16.0/20"
}

