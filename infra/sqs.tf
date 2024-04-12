# Create an SQS queue to serve as an event source for our Lambda function.
# Upon detecting a new message in the queue, SQS automatically triggers the Lambda function.
# https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html

# Define and manage Amazon Simple Queue Service (SQS) queues within AWS infrastructure.
resource "aws_sqs_queue" "queue" {
  name = "${var.app_env}-s3-event-notification-queue"

  # Explicit permissions to enable access for sending messages to SQS queue.
  policy = jsonencode({ # jsonencode -> function that encodes a given value to a string using JSON syntax.
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action   = "sqs:SendMessage"
        Resource = "arn:aws:sqs:${var.region}:*:${var.app_env}-s3-event-notification-queue"
        Condition = {
          ArnEquals: {
            "aws:SourceArn": "${aws_s3_bucket.bucket.arn}"
          }
        }
      },
    ]
  })
}

# Event source from SQS to Lambda - this allows Lambda functions to get events from SQS.
# This resource is used to configure a connection between an AWS Lambda function and an event source.
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.sqs_processor.arn
  enabled          = true  # Determines if the mapping will be enabled on creation (defualt = true).
  batch_size       = 5     # The largest number of records that Lambda will retrieve from your event source at the time of invocation.
}
