# S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.app_env}-s3-sqs-bucket-12042024"
  force_destroy = true # all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed.
}

# S3 bucket notification configuration to SQS queue.
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  # Notification configuration to SQS Queue on object created and removed.
  queue {
    queue_arn = aws_sqs_queue.queue.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}
