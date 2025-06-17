################################################################################################
# This module provisions all resources required for deploying the application stack on EKS.
# Includes ACM certificate, Route 53 validation, CloudFront security group, and Helm deployment.
# Enables secure, automated deployment of frontend and backend with HTTPS and DNS integration.
################################################################################################

resource "helm_release" "app" {
  name       = "app"
  chart      = "${path.module}/helm"
  namespace  = "default"
  upgrade_install = true
  
  set {
    name  = "frontend.image"
    value = var.frontend_image_url
  }

  set {
    name  = "backend.image"
    value = var.backend_image_url
  }

  set {
    name  = "backend.dbUrl"
    value = var.db_url
  }

  set {
    name  = "frontend.alb_hostname"
    value = var.alb_domain
  }

  set {
    name  = "frontend.cloudfront_hostname"
    value = var.cloudfront_domain
  }

  set {
    name  = "frontend.certArn"
    value = aws_acm_certificate.frontend.arn
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "projectName"
    value = var.project_name
  }

  set {
    name = "rds_secret_arn"
    value = var.rds_secret_arn
  }
}

resource "aws_acm_certificate" "frontend" {
  domain_name       = var.alb_domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "frontend_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.domain_name => {
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

  depends_on = [ aws_acm_certificate.frontend, helm_release.app  ]
}

resource "aws_acm_certificate_validation" "frontend" {
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = [for record in aws_route53_record.frontend_cert_validation : record.fqdn]
}


data "aws_ec2_managed_prefix_list" "cloudfront" {
 name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "allow_cloudfront" {
  name        = "cloudfront-sg-2"
  description = "Security group with CloudFront origin-facing prefix list"
  vpc_id      = var.vpc_id
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    prefix_list_ids  = [data.aws_ec2_managed_prefix_list.cloudfront.id]
    description      = "Allow HTTPS traffic from CloudFront"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "cloudfront-security-group"
  }
}

