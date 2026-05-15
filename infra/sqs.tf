resource "aws_sqs_queue" "event_driven_queue_lambda" {
  name                      = "event-driven-queue-sqs"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10 # long polling


  tags = {
    Environment = "dev"
    Project     = "event-driven"
  }
}