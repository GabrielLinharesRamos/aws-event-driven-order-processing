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