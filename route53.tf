resource "aws_route53_record" "pingfederate" {
  zone_id = data.aws_route53_zone.pingfederate.zone_id
  name    = local.pingfederate_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.pingfederate.dns_name
    zone_id                = aws_lb.pingfederate.zone_id
    evaluate_target_health = true
  }
}
