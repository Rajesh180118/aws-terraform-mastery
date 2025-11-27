terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
}
backend "s3" {
    bucket = "terraform-state"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt      = true

  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Create a VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "demo-vpc"
  }
}

# Create a simple S3 bucket
resource "aws_s3_bucket" "first_bucket" {
  bucket = "mys3bucketbyraja1801-${aws_vpc.demo-vpc.id}"

  tags = {
    Name   = "My bucket"
  }
}