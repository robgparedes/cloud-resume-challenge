output "api_base_url" {
  description = "Base URL of the deployed API"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "get_visitor_count_url" {
  description = "Endpoint to retrieve the visitor count"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/visitorCount"
}

output "increment_visitor_count_url" {
  description = "Endpoint to increment the visitor count"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/visitorCount/increment"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table storing the visitor count"
  value       = aws_dynamodb_table.visitor_count.name
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "frontend_url" {
  description = "Public URL of the resume site"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}