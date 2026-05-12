#DynamoDB

resource "aws_dynamodb_table" "event_driven_orders" {
  name         = "event-driven-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  tags = {
    Environment = "dev"
    Project     = "event-driven"
  }

  attribute {
    name = "id"
    type = "S"
  }
}

#lambda

# Criação do json que especifica as policies do lambda
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

# Criação do IAM role utilizando o Json assumeRole
resource "aws_iam_role" "iam_lambda" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Criação do json que especifica a policy do que o lambda pode fazer
data "aws_iam_policy_document" "lambda_permissions_policy_json" {
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
}

#criação da permission policy do lambda
resource "aws_iam_policy" "lambda_permissions_policy" {
  name        = "event_driven_lambda_dynamodb_policy"

  policy      = data.aws_iam_policy_document.lambda_permissions_policy_json.json
}

#conexão da permission policy na role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  role        = aws_iam_role.iam_lambda.name
  policy_arn  = aws_iam_policy.lambda_permissions_policy.arn
}

# Zipa a função do codigo
data "archive_file" "package" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/event-driven-create-order"
  output_path = "${path.module}/lambda/event-driven-create-order/function.zip"
}

# Função lambda
resource "aws_lambda_function" "event_driven_create_order" {
  filename          = data.archive_file.package.output_path
  function_name     = "event-driven-create-order"
  role              = aws_iam_role.iam_lambda.arn
  handler           = "index.lambda_handler"
  source_code_hash  = data.archive_file.package.output_base64sha256

  runtime = "python3.13"

  tags = {
    Environment = "dev"
    Project     = "event-driven"
  }
}


#API Gateway


# lançando o api gateway
resource "aws_apigatewayv2_api" "event_driven_api_gateway" {
  name          = "event-driven-api"
  protocol_type = "HTTP"

  tags = {
    Environment = "dev"
    Project     = "event-driven"
  }
}

# integração do API Gateway com o Lambda
resource "aws_apigatewayv2_integration" "event_driven_api_integration" {
  api_id           = aws_apigatewayv2_api.event_driven_api_gateway.id
  integration_type = "AWS_PROXY"

  payload_format_version    = "2.0"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.event_driven_create_order.invoke_arn
}

# definindo as rotas do api gateway
resource "aws_apigatewayv2_route" "event_driven_api_routes" {
  api_id    = aws_apigatewayv2_api.event_driven_api_gateway.id
  route_key = "POST /orders"

  target = "integrations/${aws_apigatewayv2_integration.event_driven_api_integration.id}"
}

# Criação do stage
resource "aws_apigatewayv2_stage" "event_driven_api_stage" {
  api_id = aws_apigatewayv2_api.event_driven_api_gateway.id
  name   = "dev"
  auto_deploy = true
}

# permissão para o API Gateway chamar o lambda
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.event_driven_create_order.arn
  principal     = "apigateway.amazonaws.com"


  source_arn = "${aws_apigatewayv2_api.event_driven_api_gateway.execution_arn}/dev/POST/orders"
}