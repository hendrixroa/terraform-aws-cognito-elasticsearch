output "elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.elasticsearch.endpoint
}

output "elasticsearch_arn" {
  value = aws_elasticsearch_domain.elasticsearch.arn
}

output "kibana_sns_role" {
  value = aws_iam_role.kibana_sns_role.arn
}