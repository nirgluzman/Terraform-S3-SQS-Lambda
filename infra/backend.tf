terraform {
  backend "s3" {
    bucket         = "remote-state-s3-12042024" # variables are not allowed within a backend block.
    key            = "env/dev/s3-sqs-lambda.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
    dynamodb_table = "remote-state-dynamodb"    # variables are not allowed within a backend block.
  }
}
