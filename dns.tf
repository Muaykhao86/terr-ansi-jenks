#Gets the already publically configured hosted zone - pre created
data "aws_route53_zone" "dns" {
  provider = aws.region-master
  name     = var.dns-name
}

#Creates the record in the hosted zone for the ACM certificate verification
resource "aws_route53_record" "cert_validation" {
  provider = aws.region-master
  for_each = {
    for val in aws_acm_certificate.jenkins-lb-https.domain_validation_options : val.domain_name => {
      name    = val.resource_record_name
      type    = val.resource_record_type
      records = val.resource_record_value
    }
  }
  name    = each.value.name
  records = [each.value.records]
  type    = each.value.type
  ttl     = 60
  zone_id = data.aws_route53_zone.dns.zone_id
}

#create route for load balancer
resource "aws_route53_record" "jenkins" {
  provider = aws.region-master
  zone_id  = data.aws_route53_zone.dns.zone_id
  name     = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  type     = "A"
  alias {
    name                   = aws_lb.application-lb.dns_name
    zone_id                = aws_lb.application-lb.zone_id
    evaluate_target_health = true
  }
}
