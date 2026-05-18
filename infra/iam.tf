
# Criação do json que especifica a trust policy das funções lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#iam do lambda_producer


# Criação do IAM role utilizando o Json assumeRole
resource "aws_iam_role" "iam_lambda_producer" {
  name               = "event-driven-create-order-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

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

#criação da permission policy do lambda_producer
resource "aws_iam_policy" "lambda_producer_permissions_policy" {
  name        = "event_driven_lambda_producer_policy"

  policy      = data.aws_iam_policy_document.lambda_producer_permissions_policy_json.json
}

#conexão da permission policy na role
resource "aws_iam_role_policy_attachment" "lambda_producer_attachment" {
  role        = aws_iam_role.iam_lambda_producer.name
  policy_arn  = aws_iam_policy.lambda_producer_permissions_policy.arn
}

# permissão para o API Gateway chamar o lambda
resource "aws_lambda_permission" "lambda_producer_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.event_driven_create_order.arn
  principal     = "apigateway.amazonaws.com"


  source_arn = "${aws_apigatewayv2_api.event_driven_api_gateway.execution_arn}/dev/POST/orders"
}

#iam do lambda_consumer

# Criação do IAM role utilizando o Json assumeRole
resource "aws_iam_role" "iam_lambda_consumer" {
  name               = "event-driven-process-order-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Criação do json que especifica a policy do que o lambda_consumer pode fazer
data "aws_iam_policy_document" "lambda_consumer_permissions_policy_json" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.event_driven_orders.arn,
    ]
  }


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
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.event_driven_queue_lambda.arn,
      ]
  }
}

#criação da permission policy do lambda_consumer
resource "aws_iam_policy" "lambda_consumer_permissions_policy" {
  name        = "event_driven_lambda_consumer_policy"

  policy      = data.aws_iam_policy_document.lambda_consumer_permissions_policy_json.json
}

#conexão da permission policy na role
resource "aws_iam_role_policy_attachment" "lambda_consumer_attachment" {
  role        = aws_iam_role.iam_lambda_consumer.name
  policy_arn  = aws_iam_policy.lambda_consumer_permissions_policy.arn
}