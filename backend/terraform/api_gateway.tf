resource "aws_apigatewayv2_api" "visitor_api" {
  name          = local.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [var.allowed_origin]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "get_visitor_count_integration" {
  api_id                 = aws_apigatewayv2_api.visitor_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_visitor_count.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "increment_visitor_count_integration" {
  api_id                 = aws_apigatewayv2_api.visitor_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.increment_visitor_count.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_visitor_count_route" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "GET /visitorCount"
  target    = "integrations/${aws_apigatewayv2_integration.get_visitor_count_integration.id}"
}

resource "aws_apigatewayv2_route" "increment_visitor_count_route" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "POST /visitorCount/increment"
  target    = "integrations/${aws_apigatewayv2_integration.increment_visitor_count_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "$default"
  auto_deploy = true
}

# -----------------------------
# Allow API Gateway to invoke Lambdas
# -----------------------------
resource "aws_lambda_permission" "allow_api_gateway_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_visitor_count.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_post" {
  statement_id  = "AllowExecutionFromAPIGatewayPost"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.increment_visitor_count.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}