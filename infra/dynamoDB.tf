resource "aws_dynamodb_table" "event_driven_orders" {
  name         = var.orders_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  tags = {
    Environment = var.tag_Environment
    Project     = var.tag_Project
  }

  attribute {
    name = "id"
    type = "S"
  }
}