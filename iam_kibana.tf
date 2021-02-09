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
      "${aws_elasticsearch_domain.es.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "kibana_sns_policy" {
  name   = "${var.name}_kibana_sns_policy"
  role   = aws_iam_role.kibana_sns_role.id
  policy = data.aws_iam_policy_document.kibana_sns_policy.json
}