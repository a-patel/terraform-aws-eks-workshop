variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "us-east-1"
}


# GENERAL INFO

variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  # description = "Name of the project deployment."
  type = string
}

variable "owner" {
  description = "Name of the project owner."
  type        = string
}

variable "billing_code" {
  description = "Name of billing code of project."
  type        = string
  default     = "Unknown"
}


# VPC Configuration

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}


# cluster
variable "k8s_service_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#kubernetes_network_config"
  type        = string
  default     = "192.168.0.0/16"
}


# Management Access
variable "office_cidr" {
  description = "CIDR Block for SG to Grant Access to Bastion/Jumpbox Instances (i.e. 192.168.100.0/24). e.g. The IP address range of your corporate office or personal computer."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "TerraformEKSWorkshop"
    "Environment" = "Development"
    "Owner"       = "Ashish Patel"
    "BillingCode" = "BILLCODE01"
    "Source"      = "Terraform"
  }
}
