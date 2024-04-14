# Create an SQS queue to serve as an event source for our Lambda function.
# Upon detecting a new message in the queue, SQS automatically triggers the Lambda function.
# https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html

# Define and manage Amazon Simple Queue Service (SQS) queues within AWS infrastructure.
resource "aws_sqs_queue" "queue" {
  name = "${var.app_env}-s3-event-notification-queue"

  delay_seconds = 20  # (Optional) The time in seconds that the delivery of all messages in the queue will be delayed; default = 0 seconds.

  # With a redrive policy, you can define how many times SQS will make the messages available for consumers.
  # After that, SQS will send it to the dead-letter queue specified in the policy.
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_deadletter.arn
    maxReceiveCount     = 4 # SQS moves messages to DLQ after the value of maxReceiveCount is exceeded.
  })

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
# DLQ - dead-letter queue.
resource "aws_sqs_queue" "queue_deadletter" {
  name = "${var.app_env}-s3-event-notification-queue-dlq"
}

# The redrive policy specifies the source queue, the dead-letter queue, and the conditions under which Amazon SQS moves messages
# from the former to the latter if the consumer of the source queue fails to process a message a specified number of times.
resource "aws_sqs_queue_redrive_allow_policy" "queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.queue_deadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue", # Only queues specified by the sourceQueueArns parameter can specify this queue as the dead-letter queue.
    sourceQueueArns   = [aws_sqs_queue.queue.arn]
  })
}

# Event source from SQS to Lambda - this allows Lambda functions to get events from SQS.
# This resource is used to configure a connection between an AWS Lambda function and an event source.
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn        = aws_sqs_queue.queue.arn
  function_name           = aws_lambda_function.sqs_processor.arn
  enabled                 = true  # Determines if the mapping will be enabled on creation (defualt = true).
  batch_size              = 5     # The largest number of records that Lambda will retrieve from your event source at the time of invocation.
  function_response_types = ["ReportBatchItemFailures"]
}
