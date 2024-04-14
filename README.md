## Terraform Tutorial - Deploying S3-SQS-Lambda Integration

- Source: https://www.youtube.com/watch?v=3E1IcVIaI0A

- GitHub repo: https://github.com/nirgluzman/Terraform-S3-SQS-Lambda.git

- Using Lambda with Amazon SQS: https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html

- Monitoring Amazon SQS queues using CloudWatch
  https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-monitoring-using-cloudwatch.html

## Implementing partial batch responses

https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#services-sqs-batchfailurereporting
https://serverlessland.com/snippets/integration-sqs-to-lambda-with-batch-item-handling

- When your Lambda function encounters an error while processing a batch, all messages in that batch
  become visible in the queue again by default, including messages that Lambda processed
  successfully (e.g. Lambda function throws an exception, the entire batch is considered a complete
  failure). As a result, your function can end up processing the same message several times.

- To avoid reprocessing successfully processed messages in a failed batch, you can configure your
  event source mapping to make only the failed messages visible again. This is called a
  `partial batch response`.

## Make your Lambda function idempotent

https://repost.aws/knowledge-center/lambda-function-idempotent

## Terraform / Remote Backend with S3 & DynamoDB - Environment Variables

- Remote backend:
  https://hackernoon.com/deploying-a-terraform-remote-state-backend-with-aws-s3-and-dynamodb

- The configuration for the `backend` cannot use variables or reference locals or data sources,
  because the backend block is evaluated before any variables are processed.

- As a fallback for the other ways of defining variables, Terraform searches for environment
  variables named `TF_VAR_` followed by the name of a declared variable.
  https://developer.hashicorp.com/terraform/language/values/variables#environment-variables

```code
terraform {
  backend "s3" {
    bucket         = var.backend_bucket
    key            = var.backend_key
    region         = var.backend_region
    dynamodb_table = var.backend_dynamodb_table
  }
}
```

```bash
export TF_VAR_backend_bucket="your-bucket"
export TF_VAR_backend_key="path/to/your/statefile"
export TF_VAR_backend_region="your-region"
export TF_VAR_backend_dynamodb_table="your-dynamodb-table"
```
