#######################################################################################################################
# This module provisions all resources required for External Secrets Operator integration with AWS Secrets Manager.wq
# Includes IAM policy, IRSA role, Kubernetes service account, and Helm deployment.
# Enables secure, automated syncing of secrets from AWS Secrets Manager to Kubernetes.
#######################################################################################################################

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets-operator"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
  version    = var.external_secrets_helm_version
  upgrade_install = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets-operator"
  }

 # values = [
 #   templatefile("${path.module}/helm/values.yaml", {
 #     rds_secret_arn = var.rds_secret_arn
 #   })
 # ]

  depends_on = [ kubernetes_service_account.external_secrets ]
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${var.project_name}-ExternalSecretsPolicy"
  description = "Policy for External Secrets Operator to access RDS secret"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.rds_secret_arn
      }
    ]
  })
}

resource "aws_iam_role" "external_secrets" {
  name = "${var.project_name}-ExternalSecretsRole"
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
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-secrets-operator"
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets-operator"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
    }
  }
}

# Wait for SecretStore CRD to be established before applying manifests
/*
resource "null_resource" "wait_for_secretstore_crd" {
  depends_on = [helm_release.external_secrets]
  provisioner "local-exec" {
    command = <<EOT
      for i in {1..30}; do
        kubectl get crd secretstores.external-secrets.io && exit 0
        sleep 5
      done
      echo "SecretStore CRD not found after waiting. Exiting." >&2
      exit 1
    EOT
  }
}
*/

/*
resource "kubectl_manifest" "secretstore" {
  yaml_body = <<-EOF
    apiVersion: external-secrets.io/v1
    kind: ClusterSecretStore
    metadata:
      name: aws-secretsmanager
    spec:
      provider:
        aws:
          service: SecretsManager
          region: eu-central-1
          auth:
            jwt:
              serviceAccountRef:
                name: external-secrets-operator
                namespace: kube-system
  EOF
  depends_on = [helm_release.external_secrets]
}
*/

/*
resource "kubectl_manifest" "db_credentials" {
  yaml_body = <<-EOF
    apiVersion: external-secrets.io/v1
    kind: ExternalSecret
    metadata:
      name: db-credentials
      namespace: default
    spec:
      refreshInterval: 5m
      secretStoreRef:
        name: aws-secretsmanager
        kind: ClusterSecretStore
      target:
        name: db-credentials
        creationPolicy: Owner
      data:
        - secretKey: DB_USER
          remoteRef:
            key: ${var.rds_secret_arn}
            property: username
        - secretKey: DB_PASSWORD
          remoteRef:
            key: ${var.rds_secret_arn}
            property: password
  EOF
  depends_on = [kubectl_manifest.secretstore]
}
*/