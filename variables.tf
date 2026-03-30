variable "project_name" {
  type        = string
  description = "Name prefix for all resources."
}

variable "vpc_name" {
  type        = string
  description = "Name tag of the existing VPC."
}

variable "route53_zone_name" {
  type        = string
  description = "Name of the existing Route 53 hosted zone."
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

variable "s3_artifact_bucket" {
  type        = string
  description = "Name of the S3 bucket containing PingFederate distribution artifacts."
}

variable "pingfederate_zip_key" {
  type        = string
  description = "S3 object key for the PingFederate distribution zip file."
}

variable "pingfederate_license_key" {
  type        = string
  description = "S3 object key for the PingFederate license file."
}

variable "nlb_internal" {
  type        = bool
  description = "Whether the NLB is internal."
  default     = true
}

variable "pingfederate_allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to reach PingFederate from outside the VPC."
  default     = []
}
