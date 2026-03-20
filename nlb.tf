resource "aws_lb" "pingfederate" {
  name_prefix        = "pf-"
  internal           = false # Set to true and update subnets to data.aws_subnets.private.ids for internal access.
  load_balancer_type = "network"
  subnets            = data.aws_subnets.public.ids

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })

  lifecycle {
    create_before_destroy = true
  }
}

# Admin Console (9999)

resource "aws_lb_target_group" "pingfederate_admin" {
  name_prefix = "pf-ad-"
  port        = 9999
  protocol    = "TLS"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "9999"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate-admin" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "pingfederate_admin" {
  load_balancer_arn = aws_lb.pingfederate.arn
  port              = 9999
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate_validation.pingfederate.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pingfederate_admin.arn
  }
}

resource "aws_lb_target_group_attachment" "pingfederate_admin" {
  target_group_arn = aws_lb_target_group.pingfederate_admin.arn
  target_id        = aws_instance.pingfederate.id
  port             = 9999
}

# Runtime Engine (9031)

resource "aws_lb_target_group" "pingfederate_runtime" {
  name_prefix = "pf-rt-"
  port        = 9031
  protocol    = "TLS"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "9031"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate-runtime" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "pingfederate_runtime" {
  load_balancer_arn = aws_lb.pingfederate.arn
  port              = 9031
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate_validation.pingfederate.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pingfederate_runtime.arn
  }
}

resource "aws_lb_target_group_attachment" "pingfederate_runtime" {
  target_group_arn = aws_lb_target_group.pingfederate_runtime.arn
  target_id        = aws_instance.pingfederate.id
  port             = 9031
}
