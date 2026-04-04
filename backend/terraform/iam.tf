resource "aws_iam_role" "get_visitor_count_role" {
  name = local.get_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "get_lambda_basic" {
  role       = aws_iam_role.get_visitor_count_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "get_visitor_count_dynamodb_policy" {
  name = "${local.get_lambda_name}-dynamodb-policy"
  role = aws_iam_role.get_visitor_count_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem"
      ]
      Resource = aws_dynamodb_table.visitor_count.arn
    }]
  })
}

resource "aws_iam_role" "increment_visitor_count_role" {
  name = local.increment_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "increment_lambda_basic" {
  role       = aws_iam_role.increment_visitor_count_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "increment_visitor_count_dynamodb_policy" {
  name = "${local.increment_lambda_name}-dynamodb-policy"
  role = aws_iam_role.increment_visitor_count_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:UpdateItem",
        "dynamodb:GetItem"
      ]
      Resource = aws_dynamodb_table.visitor_count.arn
    }]
  })
}

resource "aws_iam_role" "resume_summarizer_role" {
  name = local.summarizer_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "resume_summarizer_basic" {
  role       = aws_iam_role.resume_summarizer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "resume_summarizer_bedrock_policy" {
  name = "${local.summarizer_lambda_name}-bedrock-policy"
  role = aws_iam_role.resume_summarizer_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "bedrock:InvokeModel"
      ]
      Resource = "*"
    }]
  })
}