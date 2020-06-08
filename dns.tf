# Find the public hosted zone
data "aws_route53_zone" "base_dns" {
  name         = var.aws_base_dns_domain
  private_zone = false
}

# Create a public DNS alias for Master load balancer
resource "aws_route53_record" "master_public_dns_record" {
  zone_id = data.aws_route53_zone.base_dns.zone_id
  name    = local.cluster_master_domain
  type    = "A"
  alias {
    name                   = aws_lb.master_elb.dns_name
    zone_id                = aws_lb.master_elb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "subdomain_public_dns_record" {
  zone_id = data.aws_route53_zone.base_dns.zone_id
  name    = "*.${local.cluster_subdomain}"
  type    = "A"
  alias {
    name                   = aws_lb.master_elb.dns_name
    zone_id                = aws_lb.master_elb.zone_id
    evaluate_target_health = true
  }
}
