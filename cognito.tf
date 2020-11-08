// Cognito User pool to allow authentication swagger docs.
resource "aws_cognito_user_pool" "apidocs_pool" {
  name = var.name

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 90
  }

  lifecycle {
    ignore_changes = [
      admin_create_user_config,
    ]
  }
}

// Identity pool to allow access into apidocs
resource "aws_cognito_identity_pool" "apidocs_identity" {
  identity_pool_name               = "APIDocs Identity"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.apidocs_client.id
    provider_name           = aws_cognito_user_pool.apidocs_pool.endpoint
    server_side_token_check = false
  }

  lifecycle {
    ignore_changes = [
      allow_unauthenticated_identities,
      cognito_identity_providers,
    ]
  }
}

// App client
resource "aws_cognito_user_pool_client" "apidocs_client" {
  name = "APIDocs"

  user_pool_id = aws_cognito_user_pool.apidocs_pool.id

  generate_secret     = false
  explicit_auth_flows = ["USER_PASSWORD_AUTH"]
}

// User pool domain to render the login page to access to kibana
resource "aws_cognito_user_pool_domain" "apidocs_domain" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.apidocs_pool.id

  depends_on = [aws_cognito_user_pool.apidocs_pool]

  lifecycle {
    ignore_changes = [
      aws_account_id,
      cloudfront_distribution_arn,
      domain,
      s3_bucket,
      user_pool_id,
      version,
    ]
  }
}
