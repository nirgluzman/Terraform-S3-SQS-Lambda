resource "aws_s3_bucket" "tf-remote-state" {
  bucket = "remote-state-s3-12042024"

  force_destroy = true # Normally it must be false. Because if we delete s3 mistakenly, we lost all of the states.

  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "sse-s3" {
  bucket = aws_s3_bucket.tf-remote-state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_backend_s3" {
  bucket = aws_s3_bucket.tf-remote-state.id
  versioning_configuration {
    status = "Enabled"
  }
}
