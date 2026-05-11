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

# Criação do IAM role utilizando o Json assumeRole
resource "aws_iam_role" "iam_lambda" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# Criação do json que especifica a policy do dynamoDB
data "aws_iam_policy_document" "dynamoDB_policy_json" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.event_driven_orders.arn,
    ]
  }
}

#criação da policy do dynamoDB
resource "aws_iam_policy" "dynamoDB_policy" {
  name        = "event_driven_lambda_dynamodb_policy"
  description = "Policy for Lambda write orders into DynamoDB"

  policy      = data.aws_iam_policy_document.dynamoDB_policy_json.json
}

#conexão da policy na role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  role        = aws_iam_role.iam_lambda.name
  policy_arn  = aws_iam_policy.dynamoDB_policy.arn
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
