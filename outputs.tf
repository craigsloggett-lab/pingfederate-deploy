output "pingfederate_admin_url" {
  value       = "https://${trimsuffix(aws_route53_record.pingfederate.fqdn, ".")}:9999/pingfederate/app"
  description = "URL of the PingFederate admin console."
}

output "pingfederate_runtime_url" {
  value       = "https://${trimsuffix(aws_route53_record.pingfederate.fqdn, ".")}:9031"
  description = "URL of the PingFederate runtime engine."
}

output "pingfederate_instance_id" {
  value       = aws_instance.pingfederate.id
  description = "EC2 instance ID of the PingFederate instance."
}

output "pingfederate_private_ip" {
  value       = aws_instance.pingfederate.private_ip
  description = "Private IP address of the PingFederate instance."
}

output "pingfederate_s3_bucket" {
  value       = aws_s3_bucket.artifacts.id
  description = "S3 bucket name for PingFederate artifacts."
}
