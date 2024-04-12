# Data resource to archive Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda/lambda.zip"
}

#Lambda function declaration
resource "aws_lambda_function" "sqs_processor" {
  filename          = "${path.module}/../lambda/lambda.zip"
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256 # detect changes in lambda source code
  function_name     = "${var.app_env}-sqs_processor"
  role              = aws_iam_role.lambda_role.arn
  handler           = "index.handler"
  runtime           = "nodejs20.x"
}


# Lambda execution role for SQS processor
resource "aws_iam_role" "lambda_role" {
  name = "${var.app_env}-lambda_role"
  description = "IAM role for SQS processor Lambda function"
  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
          {
              Action = "sts:AssumeRole"
              Effect = "Allow"
              Principal = {
                  Service = "lambda.amazonaws.com"
              }
          },
      ]
  })

  # We can have more granular policy using aws_iam_role_policy and aws_iam_role_policy_attachment.
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",   # Provides write permissions to CloudWatch Logs, https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaBasicExecutionRole.html
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole" # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-eventsource
    ]
}

# # Lambda function policy
# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "${var.app_env}-lambda_policy"
#   role = aws_iam_role.lambda_role.id
#   policy = jsondecode({
#     "Version": "2012-10-17",
#     "Statement": [
#       # {
#       #   "Effect": "Allow",
#       #   "Action": [
#       #     "s3:GetObject",
#       #     "s3:PutObject"
#       #   ],
#       #   "Resource":"${aws_s3_bucket.bucket.arn}"
#       # },
#
#       {
#         "Effect": "Allow",
#         "Action": [
#           "sqs.ReceiveMessage",
#           "sqs.DeleteMessage",
#           "sqs.GetQueueAttributes"
#         ],
#         "Resource": "${aws_sqs_queue.queue.arn}"
#       },
#
#       {
#         "Effect": "Allow",
#         "Action": [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         "Resource": "arn:aws:logs:*:*:*",
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_role_policy.lambda_policy.arn
# }

# CloudWatch Log Group for Lambda function.
# Log Group to be deleted when destroying our infrastructure with 'terraform destroy'.
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sqs_processor.function_name}"
  retention_in_days = 5
}
