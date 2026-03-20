# Required

variable "project_name" {
  type        = string
  description = "Name prefix for all resources."
}

variable "route53_zone_name" {
  type        = string
  description = "Name of the existing Route 53 hosted zone."
}

variable "vpc_name" {
  type        = string
  description = "Name tag of the existing VPC."
}

variable "ec2_key_pair_name" {
  type        = string
  description = "Name of an existing EC2 key pair for SSH access."
}

variable "ec2_ami_owner" {
  type        = string
  description = "AWS account ID of the AMI owner."
}

variable "ec2_ami_name" {
  type        = string
  description = "Name filter for the AMI (supports wildcards)."
}

variable "pingfederate_zip_path" {
  type        = string
  description = "Local path to the PingFederate distribution zip file."
}

variable "pingfederate_license_path" {
  type        = string
  description = "Local path to the PingFederate license file."
}

# General

variable "common_tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

# EC2

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the PingFederate instance."
  default     = "t3.medium"
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH to the PingFederate instance."
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.ssh_allowed_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All entries must be valid CIDR blocks."
  }
}

variable "pingfederate_allowed_cidrs" {
  type        = list(string)
  description = "External CIDR blocks allowed to access PingFederate (ports 9999 and 9031)."
  default     = []

  validation {
    condition     = alltrue([for cidr in var.pingfederate_allowed_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All entries must be valid CIDR blocks."
  }
}

# PingFederate

variable "pingfederate_subdomain" {
  type        = string
  description = "Subdomain for the PingFederate DNS record."
  default     = "pingfed"
}
