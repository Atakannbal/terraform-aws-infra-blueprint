############################################################################################################
# This module provisions all resources required for a secure CloudFront CDN in front of your application.
# Includes ACM certificate, DNS validation, CloudFront distribution, and Route 53 alias record.
# Enables global, secure, and performant content delivery for your application.
############################################################################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  
  origin {
    domain_name = var.load_balancer_domain_name
    origin_id   = "${var.environment}-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  
  aliases = [var.cloudfront_domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.environment}-alb"

    compress = true
    
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Host", "Cache-Control", "ETag", "Last-Modified"]
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 3600
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
  acm_certificate_arn = aws_acm_certificate.cloudfront_cert.arn
  ssl_support_method  = "sni-only"
  minimum_protocol_version = "TLSv1.2_2018"
  }
}

resource "aws_acm_certificate" "cloudfront_cert" {
  domain_name       = var.cloudfront_domain_name
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.route53_zone_id 
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

  depends_on = [aws_acm_certificate.cloudfront_cert]
}

resource "aws_acm_certificate_validation" "cloudfront_cert_validation" {
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}



resource "aws_route53_record" "cloudfront" {
  zone_id = var.route53_zone_id
  name    = var.cloudfront_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_cloudfront_distribution.cdn]
}

