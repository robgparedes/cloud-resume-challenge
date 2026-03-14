data "aws_caller_identity" "current" {}

# -----------------------------
# DynamoDB table
# -----------------------------
resource "aws_dynamodb_table" "visitor_count" {
  name         = "${var.project_name}-visitor-count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# -----------------------------
# ZIP the Lambda code
# -----------------------------
data "archive_file" "get_visitor_count_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/getVisitorCount/lambda_function.py"
  output_path = "${path.module}/getVisitorCount.zip"
}

data "archive_file" "increment_visitor_count_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/incrementVisitorCount/lambda_function.py"
  output_path = "${path.module}/incrementVisitorCount.zip"
}

# -----------------------------
# IAM role for GET Lambda
# -----------------------------
resource "aws_iam_role" "get_visitor_count_role" {
  name = "${var.project_name}-getVisitorCount-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_lambda_basic" {
  role       = aws_iam_role.get_visitor_count_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "get_visitor_count_dynamodb_policy" {
  name = "${var.project_name}-getVisitorCount-dynamodb-policy"
  role = aws_iam_role.get_visitor_count_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.visitor_count.arn
      }
    ]
  })
}

# -----------------------------
# IAM role for POST Lambda
# -----------------------------
resource "aws_iam_role" "increment_visitor_count_role" {
  name = "${var.project_name}-incrementVisitorCount-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "increment_lambda_basic" {
  role       = aws_iam_role.increment_visitor_count_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "increment_visitor_count_dynamodb_policy" {
  name = "${var.project_name}-incrementVisitorCount-dynamodb-policy"
  role = aws_iam_role.increment_visitor_count_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.visitor_count.arn
      }
    ]
  })
}

# -----------------------------
# Lambda functions
# -----------------------------
resource "aws_lambda_function" "get_visitor_count" {
  function_name = "${var.project_name}-getVisitorCount"
  role          = aws_iam_role.get_visitor_count_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.get_visitor_count_zip.output_path
  source_code_hash = data.archive_file.get_visitor_count_zip.output_base64sha256
  timeout       = 10

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.visitor_count.name
      ALLOWED_ORIGIN = var.allowed_origin
    }
  }
}

resource "aws_lambda_function" "increment_visitor_count" {
  function_name = "${var.project_name}-incrementVisitorCount"
  role          = aws_iam_role.increment_visitor_count_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.increment_visitor_count_zip.output_path
  source_code_hash = data.archive_file.increment_visitor_count_zip.output_base64sha256
  timeout       = 10

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.visitor_count.name
      ALLOWED_ORIGIN = var.allowed_origin
    }
  }
}

# -----------------------------
# HTTP API Gateway
# -----------------------------
resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "${var.project_name}-visitor-api"
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