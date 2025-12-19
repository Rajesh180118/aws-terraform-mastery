variable "primary_region" {
  description = "The AWS region for the primary provider"
  type        = string
  default     = "us-east-1" 
}

variable "secondary_region" {
  description = "The AWS region for the secondary provider"
  type        = string
  default     = "us-west-1" 
}

variable "primary_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "secondary_cidr_block" {
  description = "The CIDR block for the secondary VPC"
  type        = string
  default     = "10.1.0.0/24"
}
variable "primary_tags" {
  description = "Tags for vpc"
  type        = map(string)
  default     = {
    Name        = "Primary-VPC"
    Environment = "Demo"
    Purpose     = "VPC-Peering-Demo"
  }
}
variable "secondary_tags" {
  description = "Tags for secondary vpc"
  type        = map(string)
  default     = {
    Name        = "Secondary-VPC"
    Environment = "Demo"
    Purpose     = "VPC-Peering-Demo"
  }
}

variable "key_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
  default     = "vpc-peering-demo"
}

variable "s3_bucket_name_primary" {
  description = "The name of the S3 bucket for VPC flow logs"
  type        = string
  default     = "primary-vpc-flow-logs-bucket-123456effdtd"  # Replace with a unique bucket name
}

variable "s3_bucket_name_secondary" {
  description = "The name of the S3 bucket for VPC flow logs"
  type        = string
  default     = "s3forflowlogs-secondary"  # Replace with a unique bucket name
}