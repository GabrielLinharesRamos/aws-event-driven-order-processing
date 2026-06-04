#usado para o github actions poder fazer deploy automatico

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated" #serviço externo
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"

        values = [
            "sts.amazonaws.com"
        ]
    }

    condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:sub"

        values = [
            "repo:GabrielLinharesRamos/aws-event-driven-order-processing:ref:refs/heads/main"
        ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"] #diferente de assumeRole por que o mecanismo de autenticação para federação é diferente
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
}

# Criação do IAM role utilizando o Json assumeRole
resource "aws_iam_role" "oicd_role" {
  name               = "${var.project_name}-oicd-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

#até aqui tudo certo

# Criação do json que especifica a policy do que o lambda_producer pode fazer
data "aws_iam_policy_document" "lambda_producer_permissions_policy_json" {

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }


  statement {
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.event_driven_queue_lambda.arn,
      ]
  }
}

#conexão da permission policy na role
resource "aws_iam_role_policy_attachment" "lambda_producer_attachment" {
  role        = aws_iam_role.iam_lambda_producer.name
  policy_arn  = aws_iam_policy.lambda_producer_permissions_policy.arn
}