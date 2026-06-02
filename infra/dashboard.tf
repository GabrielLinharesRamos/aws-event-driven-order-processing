resource "aws_cloudwatch_dashboard" "system_metrics" {
  dashboard_name = "${var.project_name}-system_metrics"

  dashboard_body = jsonencode({
    "widgets": [
        {
            "type": "metric",
            "x": 17,
            "y": 0,
            "width": 7,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "event-driven-create-order" ],
                    [ ".", "Duration", ".", "." ],
                    [ ".", "Errors", ".", "." ]
                ],
                "region": "sa-east-1",
                "title": " event-driven-create-order"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 7,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "event-driven-process-order" ],
                    [ ".", "Invocations", ".", "." ],
                    [ ".", "Errors", ".", "." ]
                ],
                "region": "sa-east-1",
                "title": " event-driven-process-order"
            }
        },
        {
            "type": "metric",
            "x": 7,
            "y": 0,
            "width": 10,
            "height": 9,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "event-driven-orders-deadletter-queue" ]
                ],
                "region": "sa-east-1",
                "title": "DLQ - messages"
            }
        }
    ]
})
}