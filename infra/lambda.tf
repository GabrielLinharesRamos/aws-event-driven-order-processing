# Zipa a função do codigo
data "archive_file" "package" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/event-driven-create-order"
  output_path = "${path.module}/../lambda/event-driven-create-order/function.zip"
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