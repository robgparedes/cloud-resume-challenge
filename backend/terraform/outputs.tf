output "api_base_url" {
  value = aws_apigatewayv2_api.visitor_api.api_endpoint
}

output "get_visitor_count_url" {
  value = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/visitorCount"
}

output "increment_visitor_count_url" {
  value = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/visitorCount/increment"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.visitor_count.name
}