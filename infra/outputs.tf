output "api_url" {
  value = aws_apigatewayv2_stage.event_driven_api_stage.invoke_url
}