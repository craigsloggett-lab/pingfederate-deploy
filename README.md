# PingFederate Deployment

Terraform configuration to deploy a single PingFederate instance on AWS, running
as a Docker container on EC2.

## Architecture

- Single EC2 instance in a private subnet running PingFederate in Docker
- PingFederate distribution zip and license uploaded to S3, downloaded at boot via cloud-init
- Internet-facing NLB with TCP passthrough on ports 9999 (admin console) and 9031 (runtime engine)
- Route 53 DNS alias to the NLB
- AMI discovered by owner and name filter (defaults to Ubuntu)
- Private and public subnets discovered automatically from the existing VPC

## Prerequisites

- An existing VPC with public and private subnets
- A Route 53 hosted zone
- An EC2 key pair
- An Ubuntu or Debian-based AMI
- The PingFederate distribution zip file
- A PingFederate license file

## Post-deployment

After `terraform apply`, cloud-init installs Docker, downloads the PingFederate
artifacts from S3, builds a container image, and starts the service. This takes
roughly 5-10 minutes. Monitor progress by SSHing into the instance:

```bash
sudo tail -f /var/log/cloud-init-output.log
```

PingFederate is ready when the container logs show the server has started:

```bash
sudo docker logs -f pingfederate
```

## Network access

The NLB is internet-facing and the VPC CIDR is always allowed. By default, no
external CIDR blocks are permitted. To make PingFederate accessible from the
internet, provide the CIDR blocks that should be allowed to reach ports 9999
and 9031:

```hcl
pingfederate_allowed_cidrs = ["0.0.0.0/0"]
```

This adds security group rules for the specified CIDRs. The EC2 instance remains
in a private subnet — only the NLB is internet-facing. Restrict
`pingfederate_allowed_cidrs` to known ranges where possible.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_ec2_ami_name"></a> [ec2\_ami\_name](#input\_ec2\_ami\_name) | Name filter for the AMI (supports wildcards). | `string` | n/a | yes |
| <a name="input_ec2_ami_owner"></a> [ec2\_ami\_owner](#input\_ec2\_ami\_owner) | AWS account ID of the AMI owner. | `string` | n/a | yes |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | Name of an existing EC2 key pair for SSH access. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for the PingFederate instance. | `string` | `"t3.medium"` | no |
| <a name="input_pingfederate_allowed_cidrs"></a> [pingfederate\_allowed\_cidrs](#input\_pingfederate\_allowed\_cidrs) | External CIDR blocks allowed to access PingFederate (ports 9999 and 9031). | `list(string)` | `[]` | no |
| <a name="input_pingfederate_license_path"></a> [pingfederate\_license\_path](#input\_pingfederate\_license\_path) | Local path to the PingFederate license file. | `string` | n/a | yes |
| <a name="input_pingfederate_subdomain"></a> [pingfederate\_subdomain](#input\_pingfederate\_subdomain) | Subdomain for the PingFederate DNS record. | `string` | `"pingfed"` | no |
| <a name="input_pingfederate_zip_path"></a> [pingfederate\_zip\_path](#input\_pingfederate\_zip\_path) | Local path to the PingFederate distribution zip file. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name prefix for all resources. | `string` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Name of the existing Route 53 hosted zone. | `string` | n/a | yes |
| <a name="input_ssh_allowed_cidrs"></a> [ssh\_allowed\_cidrs](#input\_ssh\_allowed\_cidrs) | CIDR blocks allowed to SSH to the PingFederate instance. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name tag of the existing VPC. | `string` | n/a | yes |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_iam_instance_profile.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.pingfederate_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lb.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.pingfederate_license](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.pingfederate_zip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.pingfederate_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_admin_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_runtime_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.pingfederate_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pingfederate_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pingfederate_admin_url"></a> [pingfederate\_admin\_url](#output\_pingfederate\_admin\_url) | URL of the PingFederate admin console. |
| <a name="output_pingfederate_instance_id"></a> [pingfederate\_instance\_id](#output\_pingfederate\_instance\_id) | EC2 instance ID of the PingFederate instance. |
| <a name="output_pingfederate_private_ip"></a> [pingfederate\_private\_ip](#output\_pingfederate\_private\_ip) | Private IP address of the PingFederate instance. |
| <a name="output_pingfederate_runtime_url"></a> [pingfederate\_runtime\_url](#output\_pingfederate\_runtime\_url) | URL of the PingFederate runtime engine. |
| <a name="output_pingfederate_s3_bucket"></a> [pingfederate\_s3\_bucket](#output\_pingfederate\_s3\_bucket) | S3 bucket name for PingFederate artifacts. |
<!-- END_TF_DOCS -->
