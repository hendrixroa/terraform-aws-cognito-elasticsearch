data "aws_iam_policy_document" "cognito_es_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:DescribeUserPool",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:DescribeUserPoolClient",
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUserPoolClients",
      "cognito-identity:DescribeIdentityPool",
      "cognito-identity:UpdateIdentityPool",
      "cognito-identity:SetIdentityPoolRoles",
      "cognito-identity:GetIdentityPoolRoles"
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "es_assume_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "es_access_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${lookup(module.cognito.cognito_map, "auth_arn")}"]
    }
    actions = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${var.account_id}:domain/${var.elasticsearch_domain_name}/*"]
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_iam_policy" "cognito_es_policy" {
  name = "${var.name}-COGNITO-ACCESS-ES-POLICY"
  policy = data.aws_iam_policy_document.cognito_es_policy.json
}


resource "aws_iam_role" "cognito_es_role" {
  name = "${var.name}-COGNITO-ACCESS-ES-ROLE"
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy.json

}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  role       = aws_iam_role.cognito_es_role.name
  policy_arn = aws_iam_policy.cognito_es_policy.arn
}
