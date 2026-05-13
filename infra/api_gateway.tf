# lançando o api gateway
resource "aws_apigatewayv2_api" "event_driven_api_gateway" {
  name          = "event-driven-api"
  protocol_type = "HTTP"

  tags = {
    Environment = "dev"
    Project     = "event-driven"
  }
}

# integração do API Gateway com o Lambda
resource "aws_apigatewayv2_integration" "event_driven_api_integration" {
  api_id           = aws_apigatewayv2_api.event_driven_api_gateway.id
  integration_type = "AWS_PROXY"

  payload_format_version    = "2.0"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.event_driven_create_order.invoke_arn
}

# definindo as rotas do api gateway
resource "aws_apigatewayv2_route" "event_driven_api_routes" {
  api_id    = aws_apigatewayv2_api.event_driven_api_gateway.id
  route_key = "POST /orders"

  target = "integrations/${aws_apigatewayv2_integration.event_driven_api_integration.id}"
}

# Criação do stage
resource "aws_apigatewayv2_stage" "event_driven_api_stage" {
  api_id = aws_apigatewayv2_api.event_driven_api_gateway.id
  name   = "dev"
  auto_deploy = true
}