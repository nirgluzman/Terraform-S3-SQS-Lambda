resource "aws_dynamodb_table" "tf-remote-state-lock" {
  name     = "remote-state-dynamodb"

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"

  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}
