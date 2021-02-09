output "elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.es.endpoint
}

output "elasticsearch_arn" {
  value = aws_elasticsearch_domain.es.arn
}

output "kibana_sns_role" {
  value = aws_iam_role.kibana_sns_role.arn
}