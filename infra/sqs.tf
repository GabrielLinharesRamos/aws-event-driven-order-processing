#SQS
resource "aws_sqs_queue" "event_driven_queue_lambda" {
  name                      = "${var.project_name}-orders-queue-sqs"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10 # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter.arn
    maxReceiveCount     = 3
  })

  tags = {
    Environment = var.tag_Environment
    Project     = var.tag_Project
  }
}

#DLQ
resource "aws_sqs_queue" "deadletter" {
  name = "${var.project_name}-orders-deadletter-queue"

  tags = {
    Environment = var.tag_Environment
    Project     = var.tag_Project
  }
}

#trigger da fila sqs

resource "aws_lambda_event_source_mapping" "process_order_sqs_trigger" {
  event_source_arn = aws_sqs_queue.event_driven_queue_lambda.arn
  function_name    = aws_lambda_function.event_driven_process_order.arn
  batch_size       = 1
}