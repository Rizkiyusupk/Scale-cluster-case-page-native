resource "aws_lambda_function" "lambda-function-alert" {
  filename         = "${path.module}/lambda_function_alert.zip"
  function_name    = "lambda_function_alert"
  role             = aws_iam_role.lambda-consumer-role.arn
  handler          = "lambda_function_alert.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_alert.zip")
  runtime          = "python3.12"
  timeout          = 10

  environment {
    variables = {
      TELEGRAM_BOT_TOKEN = var.telegram_bot_token
      TELEGRAM_CHAT_ID   = var.telegram_chat_id
    }
  }
}

resource "aws_lambda_permission" "alerts_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function-alert.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

resource "aws_sns_topic_subscription" "alerts_lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda-function-alert.arn
}