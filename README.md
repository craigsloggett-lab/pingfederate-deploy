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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pingfederate"></a> [pingfederate](#module\_pingfederate) | git::https://github.com/craigsloggett/terraform-aws-pingfederate | v0.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_ami_name"></a> [ec2\_ami\_name](#input\_ec2\_ami\_name) | Name filter for the AMI (supports wildcards). | `string` | n/a | yes |
| <a name="input_ec2_ami_owner"></a> [ec2\_ami\_owner](#input\_ec2\_ami\_owner) | AWS account ID of the AMI owner. | `string` | n/a | yes |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | Name of an existing EC2 key pair for SSH access. | `string` | n/a | yes |
| <a name="input_nlb_internal"></a> [nlb\_internal](#input\_nlb\_internal) | Whether the NLB is internal. | `bool` | `true` | no |
| <a name="input_pingfederate_allowed_cidrs"></a> [pingfederate\_allowed\_cidrs](#input\_pingfederate\_allowed\_cidrs) | CIDR blocks allowed to reach PingFederate from outside the VPC. | `list(string)` | `[]` | no |
| <a name="input_pingfederate_license_key"></a> [pingfederate\_license\_key](#input\_pingfederate\_license\_key) | S3 object key for the PingFederate license file. | `string` | n/a | yes |
| <a name="input_pingfederate_zip_key"></a> [pingfederate\_zip\_key](#input\_pingfederate\_zip\_key) | S3 object key for the PingFederate distribution zip file. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name prefix for all resources. | `string` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Name of the existing Route 53 hosted zone. | `string` | n/a | yes |
| <a name="input_s3_artifact_bucket"></a> [s3\_artifact\_bucket](#input\_s3\_artifact\_bucket) | Name of the S3 bucket containing PingFederate distribution artifacts. | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name tag of the existing VPC. | `string` | n/a | yes |

## Resources

| Name | Type |
|------|------|
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_route53_zone.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | Public IP of the bastion host. |
| <a name="output_ec2_ami_name"></a> [ec2\_ami\_name](#output\_ec2\_ami\_name) | Name of the AMI used for EC2 instances. |
| <a name="output_pingfederate_admin_url"></a> [pingfederate\_admin\_url](#output\_pingfederate\_admin\_url) | URL of the PingFederate admin console. |
| <a name="output_pingfederate_instance_id"></a> [pingfederate\_instance\_id](#output\_pingfederate\_instance\_id) | Instance ID of the PingFederate instance. |
| <a name="output_pingfederate_private_ip"></a> [pingfederate\_private\_ip](#output\_pingfederate\_private\_ip) | Private IP of the PingFederate instance. |
| <a name="output_pingfederate_runtime_url"></a> [pingfederate\_runtime\_url](#output\_pingfederate\_runtime\_url) | URL of the PingFederate runtime engine. |
<!-- END_TF_DOCS -->
