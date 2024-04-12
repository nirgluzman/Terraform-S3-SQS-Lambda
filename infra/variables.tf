variable "region" {
  default = "us-east-1"
  description = "AWS deployment region"
}

variable "app_env" {
  default = "dev"
  description = "common prefix for all Terraform created resources"
}
