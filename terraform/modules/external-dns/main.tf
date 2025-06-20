##########################################################################################################
# This module provisions all resources required for External DNS integration with AWS Route 53.
# Includes IAM role and policy for IRSA, Helm deployment, and cleanup automation for Route 53 records.
# Enables automated DNS record management for Kubernetes services in your EKS cluster.
##########################################################################################################

resource "aws_iam_role" "external_dns" {
  name = "${var.project_name}-${var.environment}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "external_dns_policy" {
  name   = "${var.project_name}-${var.environment}-external-dns-policy"
  role   = aws_iam_role.external_dns.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/${var.hosted_zone_id}",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "${path.module}/helm"
  namespace  = "kube-system"
  upgrade_install = true

  set {
    name  = "roleArn"
    value = aws_iam_role.external_dns.arn
  }

  set {
    name  = "domainFilter"
    value = var.hosted_zone_domain_name
  }

  set {
    name = "exludeDomains"
    value = var.cloudfront_domain_name
  }

  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }
  
  set {
    name  = "region"
    value = var.region
  }

  set {
    name = "version"
    value = var.eks_external_dns_version
  }
}

/*
resource "null_resource" "cleanup_route53" {
  triggers = {
    destroy_trigger = "${var.vpc_id}"
  }

  provisioner "local-exec" {
    command = <<EOT
    aws route53 list-resource-record-sets --hosted-zone-id ${var.hosted_zone_id} | \
    jq -r '.ResourceRecordSets[] | select(.Type != "NS" and .Type != "SOA") | .Name' | \
    xargs -I {} aws route53 change-resource-record-sets --hosted-zone-id ${var.hosted_zone_id} --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":{"Name":"{}","Type":"A","TTL":300,"ResourceRecords":[{"Value":"192.0.2.1"}]}}]}'
    EOT
  }

}
*/