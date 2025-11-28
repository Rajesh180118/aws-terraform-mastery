terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
}
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "mys3bucketbyraja1801testingvariable"
  
}
variable "random_suffix" {
  description = "Random suffix to ensure unique bucket name"
  type        = string
  default     = "001"
}

locals {
    bucket_name_locals = "${var.bucket_name}-${var.random_suffix}-newtesting"
}

output "bucket_arn" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.first_bucket.arn
}

output "name" {
  value = aws_s3_bucket.first_bucket.bucket
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
# Create a simple S3 bucket
resource "aws_s3_bucket" "first_bucket" {
#   bucket = local.bucket_name_locals  // Using local variable
    bucket = var.bucket_name // Using variable directly or tfvars value 
  tags = {
    Name   = "My bucket"
  }
}