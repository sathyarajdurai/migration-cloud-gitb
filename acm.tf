resource "aws_acm_certificate" "mig_cert" {
  domain_name               = "capci-gp4.aws.crlabs.cloud"
  subject_alternative_names = ["*.capci-gp4.aws.crlabs.cloud"]
  validation_method         = "DNS"


  tags = {
    Environment = "Migration"
  }

  #   provider = aws.virgina

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_route53_record" "lb_validate" {
  for_each = {
    for dvo in aws_acm_certificate.mig_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.public_member.zone_id
}


