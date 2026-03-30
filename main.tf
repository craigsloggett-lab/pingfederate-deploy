data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-private-*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-public-*"]
  }
}

data "aws_route53_zone" "pingfederate" {
  name = var.route53_zone_name
}

data "aws_ami" "selected" {
  most_recent = true
  owners      = [var.ec2_ami_owner]

  filter {
    name   = "name"
    values = [var.ec2_ami_name]
  }
}

module "pingfederate" {
  source = "git::https://github.com/craigsloggett/terraform-aws-pingfederate?ref=v0.1.0"

  project_name      = var.project_name
  route53_zone      = data.aws_route53_zone.pingfederate
  ec2_key_pair_name = var.ec2_key_pair_name
  ec2_ami           = data.aws_ami.selected

  existing_vpc = {
    vpc_id             = data.aws_vpc.selected.id
    private_subnet_ids = data.aws_subnets.private.ids
    public_subnet_ids  = data.aws_subnets.public.ids
  }

  s3_artifact_bucket       = var.s3_artifact_bucket
  pingfederate_zip_key     = var.pingfederate_zip_key
  pingfederate_license_key = var.pingfederate_license_key

  nlb_internal               = var.nlb_internal
  pingfederate_allowed_cidrs = var.pingfederate_allowed_cidrs
}
