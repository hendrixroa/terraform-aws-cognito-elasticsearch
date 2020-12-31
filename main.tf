// - Enabled Cognito to access to Kibana<br/>
// - Version Elasticsearch: 7.7<br/>
// - Encryption at rest and node2node
resource "aws_elasticsearch_domain" "elasticsearch" {
  domain_name           = var.elasticsearch_domain_name
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type  = var.elasticsearch_instance
    instance_count = var.elasticsearch_instance_count
  }


  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  access_policies = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "CognitoAccessPolicy",
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "arn:aws:sts::${var.account_id}:assumed-role/${aws_iam_role.cognito_authenticated.name}/CognitoIdentityCredentials",
              "${var.account_id}"
            ]
          },
          "Action": "es:*",
          "Resource": "arn:aws:es:${var.region}:${var.account_id}:domain/${var.elasticsearch_domain_name}/*"
        }
      ]
    }

POLICY


  ebs_options {
    ebs_enabled = true
    volume_type = "standard"
    volume_size = 35
  }

  cognito_options {
    enabled          = true
    user_pool_id     = aws_cognito_user_pool.apidocs_pool.id
    identity_pool_id = aws_cognito_identity_pool.apidocs_identity.id
    role_arn         = aws_iam_role.elasticsearch_access_cognito.arn
  }

  encrypt_at_rest {
    enabled = false
  }

  node_to_node_encryption {
    enabled = true
  }

  depends_on = [
    aws_cognito_user_pool.apidocs_pool,
    aws_cognito_user_pool_domain.apidocs_domain,
    aws_cognito_identity_pool.apidocs_identity,
    aws_iam_role.cognito_authenticated,
    aws_iam_role.elasticsearch_access_cognito,
  ]

  lifecycle {
    ignore_changes = [
      access_policies,
      cognito_options,
    ]
  }
}
