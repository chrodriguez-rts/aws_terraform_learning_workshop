locals {
  # OIDC issuer URL without the "https://" prefix
    oidc_issuer = trimprefix(
    aws_eks_cluster.main.identity[0].oidc[0].issuer,
    "https://"
    )
}

# Terraform — IRSA configuration
resource "aws_iam_role" "app_role" {
  name = "my-app-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:my-app:my-app-sa"
        }
      }
      
    }]
  })

  tags = {
        Name        = "my-app-role-${var.environment}"
        Environment = var.environment
        ManagedBy   = "Terraform"
      }
}

resource "aws_iam_role_policy" "app_secrets" {
  role = aws_iam_role.app_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "arn:aws:secretsmanager:us-east-1:468278742450:secret:my-app/*"
    }]
  })
}