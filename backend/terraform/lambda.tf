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

data "archive_file" "resume_summarizer_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/resumeSummarizer/resume_summarizer.py"
  output_path = "${path.module}/resumeSummarizer.zip"
}

resource "aws_lambda_function" "get_visitor_count" {
  function_name = local.get_lambda_name
  role          = aws_iam_role.get_visitor_count_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.get_visitor_count_zip.output_path
  source_code_hash = data.archive_file.get_visitor_count_zip.output_base64sha256

  timeout = 10

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.visitor_count.name
      ALLOWED_ORIGIN = var.allowed_origin
    }
  }
}

resource "aws_lambda_function" "increment_visitor_count" {
  function_name = local.increment_lambda_name
  role          = aws_iam_role.increment_visitor_count_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.increment_visitor_count_zip.output_path
  source_code_hash = data.archive_file.increment_visitor_count_zip.output_base64sha256

  timeout = 10

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.visitor_count.name
      ALLOWED_ORIGIN = var.allowed_origin
    }
  }
}

resource "aws_lambda_function" "resume_summarizer" {
  function_name = local.summarizer_lambda_name
  role          = aws_iam_role.resume_summarizer_role.arn
  handler       = "resume_summarizer.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.resume_summarizer_zip.output_path
  source_code_hash = data.archive_file.resume_summarizer_zip.output_base64sha256

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      MODEL_ID       = "anthropic.claude-3-haiku-20240307-v1:0"
      BEDROCK_REGION = "ap-southeast-2"
      ALLOWED_ORIGIN = var.allowed_origin
    }
  }
}