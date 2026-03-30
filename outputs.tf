output "pingfederate_admin_url" {
  description = "URL of the PingFederate admin console."
  value       = module.pingfederate.pingfederate_admin_url
}

output "pingfederate_runtime_url" {
  description = "URL of the PingFederate runtime engine."
  value       = module.pingfederate.pingfederate_runtime_url
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host."
  value       = module.pingfederate.bastion_public_ip
}

output "pingfederate_private_ip" {
  description = "Private IP of the PingFederate instance."
  value       = module.pingfederate.pingfederate_private_ip
}

output "pingfederate_instance_id" {
  description = "Instance ID of the PingFederate instance."
  value       = module.pingfederate.pingfederate_instance_id
}

output "ec2_ami_name" {
  description = "Name of the AMI used for EC2 instances."
  value       = module.pingfederate.ec2_ami_name
}
