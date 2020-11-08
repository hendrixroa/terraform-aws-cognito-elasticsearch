resource "aws_iam_role" "cognito_authenticated" {
  name = "${var.name}_cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "cognito_authenticated" {
  name = "${var.name}_authenticated_policy"
  role = aws_iam_role.cognito_authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_role" "cognito_unauthenticated" {
  name = "${var.name}_cognito_unauthenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "cognito_unauthenticated" {
  name = "${var.name}_unauthenticated_policy"
  role = aws_iam_role.cognito_unauthenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

}

resource "aws_cognito_identity_pool_roles_attachment" "cognito" {
  identity_pool_id = aws_cognito_identity_pool.identity.id

  roles = {
    "authenticated"   = aws_iam_role.cognito_authenticated.arn
    "unauthenticated" = aws_iam_role.cognito_unauthenticated.arn
  }

  lifecycle {
    ignore_changes = [
      id,
      identity_pool_id,
      roles,
    ]
  }
}


resource "aws_iam_role" "elasticsearch_access_cognito" {
  name = "${var.name}_ESAccessCognito"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "elasticsearch_access_cognito" {
  statement {
    effect    = "Allow"
    resources = ["*"]

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
      "cognito-identity:GetIdentityPoolRoles",
    ]
  }

  statement {
    effect    = "Allow"
    resources = [aws_iam_role.elasticsearch_access_cognito.arn]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"

      values = [
        "cognito-identity.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "elasticsearch_access_cognito" {
  name   = "${var.name}_elasticsearch_access_cognito_policy"
  policy = data.aws_iam_policy_document.elasticsearch_access_cognito.json
  role   = aws_iam_role.elasticsearch_access_cognito.id
}

// IAM Role to allow Kibana monitoring send notifications to sns topic
resource "aws_iam_role" "kibana_sns_role" {
  name = "${var.name}_kibana_sns_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "kibana_sns_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      var.sns_topic_arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "es:*",
    ]

    resources = [
      "${aws_elasticsearch_domain.elasticsearch.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "kibana_sns_policy" {
  name   = "${var.name}_kibana_sns_policy"
  role   = aws_iam_role.kibana_sns_role.id
  policy = data.aws_iam_policy_document.kibana_sns_policy.json
}