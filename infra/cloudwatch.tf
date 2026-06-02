
# cloudwatch alarm (PRODUCER)
resource "aws_cloudwatch_metric_alarm" "producer_monitoring_alarm" {
  alarm_name                = "${var.project_name}-producer-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 0
  alarm_description         = "This alarm monitors producer lambda errors"

  dimensions                = {
    FunctionName = aws_lambda_function.event_driven_create_order.function_name
  }
}

# cloudwatch alarm (CONSUMER)
resource "aws_cloudwatch_metric_alarm" "consumer_monitoring_alarm" {
  alarm_name                = "${var.project_name}-consumer-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 0
  alarm_description         = "This alarm monitors consumer lambda errors"

  dimensions                = {
    FunctionName  = aws_lambda_function.event_driven_process_order.function_name
  }
}

#cloudwatch alarm (DLQ)
resource "aws_cloudwatch_metric_alarm" "dlq_monitoring_alarm" {
  alarm_name                = "${var.project_name}-dlq-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "ApproximateNumberOfMessagesVisible"
  namespace                 = "AWS/SQS"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 0
  alarm_description         = "This alarm monitors dlq messages"

  dimensions                = {
    QueueName = aws_sqs_queue.deadletter.name
  }
}