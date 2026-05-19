resource "aws_sqs_queue" "event_driven_queue_lambda" {
  name                      = "${var.project_name}-queue-sqs"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10 # long polling


  tags = {
    Environment = var.tag_Environment
    Project     = var.tag_Project
  }
}

resource "aws_lambda_event_source_mapping" "process_order_sqs_trigger" {
  event_source_arn = aws_sqs_queue.event_driven_queue_lambda.arn
  function_name    = aws_lambda_function.event_driven_process_order.arn
  batch_size       = 1
}