#função producer

# Zipa o codigo da função producer
data "archive_file" "package_producer" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/event-driven-create-order"
  output_path = "${path.module}/../lambda/event-driven-create-order/function.zip"
}

# Função lambda producer
resource "aws_lambda_function" "event_driven_create_order" {
  filename          = data.archive_file.package_producer.output_path
  function_name     = "event-driven-create-order"
  role              = aws_iam_role.iam_lambda_producer.arn
  handler           = "index.lambda_handler"
  source_code_hash  = data.archive_file.package_producer.output_base64sha256

  runtime = "python3.13"

  tags = {
    Environment = "dev"
    Project     = "event-driven"
  }
}

#função consumer

# Zipa o codigo da função consumer
data "archive_file" "package_consumer" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/event-driven-process-order"
  output_path = "${path.module}/../lambda/event-driven-process-order/function.zip"
}

# Função lambda consumer
resource "aws_lambda_function" "event_driven_process_order" {
  filename          = data.archive_file.package_consumer.output_path
  function_name     = "event-driven-process-order"
  role              = aws_iam_role.iam_lambda_consumer.arn
  handler           = "index.lambda_handler"
  source_code_hash  = data.archive_file.package_consumer.output_base64sha256

  runtime = "python3.13"

  tags = {
    Environment = "dev"
    Project     = "event-driven"
  }
}