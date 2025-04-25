# Route 53 hosted zone for the domain
resource "aws_route53_zone" "primary" {
  name = var.domain_name
  tags = {
    Name = "ce-project-hosted-zone"
  }
  force_destroy = true # Allow deletion of the hosted zone even if it has records
}

# IAM role for External DNS to manage Route 53 records
resource "aws_iam_role" "external_dns" {
  name = "${var.project_name}-${var.environment}-external-dns-role"

# Allow the External DNS service account to assume this role via IRSA
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

# IAM policy for External DNS to manage Route 53 records
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
          "arn:aws:route53:::hostedzone/${aws_route53_zone.primary.zone_id}"
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

  depends_on = [aws_route53_zone.primary]
}

# Helm release for External DNS to manage Route 53 records
resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "${path.module}/helm"
  namespace  = "kube-system"

  # IAM role ARN for External DNS
  set {
    name  = "roleArn"
    value = aws_iam_role.external_dns.arn
  }

  # Domain filter to manage records for your domain
  set {
    name  = "domainFilter"
    value = var.domain_name
  }

  # Identifier for TXT records created by External DNS
  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }
  
  # AWS region
  set {
    name  = "region"
    value = var.region
  }

  set {
    name = "version"
    value = var.eks_external_dns_version
  }
}

resource "null_resource" "cleanup_route53" {
  triggers = {
    destroy_trigger = "${var.vpc_id}" # Trigger only when the VPC is being destroyed
  }

  provisioner "local-exec" {
    command = <<EOT
    aws route53 list-resource-record-sets --hosted-zone-id ${aws_route53_zone.primary.zone_id} | \
    jq -r '.ResourceRecordSets[] | select(.Type != "NS" and .Type != "SOA") | .Name' | \
    xargs -I {} aws route53 change-resource-record-sets --hosted-zone-id ${aws_route53_zone.primary.zone_id} --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":{"Name":"{}","Type":"A","TTL":300,"ResourceRecords":[{"Value":"192.0.2.1"}]}}]}'
    EOT
  }

  depends_on = [aws_route53_zone.primary]
}