

resource "aws_lambda_function" "resume_summarizer" {
  function_name = "resume-summarizer"

  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  role = "arn:aws:sts::490058394460:assumed-role/AWSReservedSSO_AdministratorAccess_101e2e669b6d2798/admin"

  # TEMP placeholders (required so Terraform accepts the config)
filename         = "placeholder.zip"
source_code_hash = "placeholder"
}