#Intitalize Credentials
provider "aws" {
  access_key = "access_key"
  secret_key = "secret_key"
  region = "us-east-1"
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "greet_lambda.zip"
  source_file = "greet_lambda.py"
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_log_group" "logs_lambda" {
  name              = "/aws/lambda/greet_lambda"
  retention_in_days = 14
}

resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_iam"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "greet_lambda" {
  filename         = "greet_lambda.zip"
  function_name    = "greet_lambda"
  handler          = "greet_lambda.lambda_handler"
  role             = aws_iam_role.lambda_iam.arn
  source_code_hash = data.archive_file.lambda.output_base64sha256
  depends_on       = [aws_cloudwatch_log_group.logs_lambda]

  runtime = var.runtime
  environment {
    variables = {
      greeting = "Hello, World!"
    }
  }
}