output "elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.es.endpoint
}

output "elasticsearch_arn" {
  value = aws_elasticsearch_domain.es.arn
}

output "kibana_sns_role" {
  value = aws_iam_role.kibana_sns_role.arn
}

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_identity_pool_id" {
  value =module.cognito.identity_pool_id
}

output "cognito_app_client_id" {
  value = module.cognito.app_client_id
}