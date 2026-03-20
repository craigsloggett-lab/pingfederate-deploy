resource "aws_instance" "pingfederate" {
  ami                    = data.aws_ami.selected.id
  instance_type          = var.instance_type
  key_name               = var.ec2_key_pair_name
  subnet_id              = data.aws_subnets.private.ids[0]
  vpc_security_group_ids = [aws_security_group.pingfederate.id]
  iam_instance_profile   = aws_iam_instance_profile.pingfederate.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = templatefile("${path.module}/templates/cloud-init.sh.tftpl", {
    region                   = data.aws_region.current.region
    s3_bucket                = aws_s3_bucket.artifacts.id
    pingfederate_zip_key     = aws_s3_object.pingfederate_zip.key
    pingfederate_license_key = aws_s3_object.pingfederate_license.key
    admin_password           = var.pingfederate_admin_password
  })

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })

  depends_on = [
    aws_iam_role_policy.pingfederate_s3,
  ]

  lifecycle {
    precondition {
      condition     = can(regex("(ubuntu|debian)", lower(data.aws_ami.selected.name)))
      error_message = "The provided AMI must be Ubuntu or Debian-based."
    }
  }
}

# Security Group

resource "aws_security_group" "pingfederate" {
  name_prefix = "${var.project_name}-pingfederate-"
  description = "Security group for the PingFederate instance"
  vpc_id      = data.aws_vpc.selected.id

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_admin" {
  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate admin console from VPC"
  from_port         = 9999
  to_port           = 9999
  ip_protocol       = "tcp"
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_admin_external" {
  for_each = toset(var.pingfederate_allowed_cidrs)

  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate admin console from external CIDR"
  from_port         = 9999
  to_port           = 9999
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_runtime" {
  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate runtime engine from VPC"
  from_port         = 9031
  to_port           = 9031
  ip_protocol       = "tcp"
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_runtime_external" {
  for_each = toset(var.pingfederate_allowed_cidrs)

  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate runtime engine from external CIDR"
  from_port         = 9031
  to_port           = 9031
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_ssh" {
  for_each = toset(var.ssh_allowed_cidrs)

  security_group_id = aws_security_group.pingfederate.id
  description       = "SSH from allowed CIDR"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "pingfederate_all" {
  security_group_id = aws_security_group.pingfederate.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
