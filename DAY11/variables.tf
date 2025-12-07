#Assignment 1
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "Project Terraform DAY11"
}

#Assignment 2
variable "default_tags" {
  description = "A map of default tags to apply to all resources"
  type        = map(string)
  default     = {
    comapany = "TechCorp"
    CostCenter = "IT001"
  }
}
variable "environment_tags" {
  description = "A map of environment-specific tags"
  type        = map(string)
  default     = {
    Environment = "Prod"
    Owner       = "Devops Team"
  }
}

#Assignment 3
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "Project DAY11 Bucketname in terraform with hypen using function "  
}

#assignment 4
variable "allowed_ports" {
  default = "80,443,8080,3306"
}

#Assignment 5
variable "instance_region" {
  default = {
    dev     = "us-east-1"
    staging = "us-east-2"
    prod    = "us-west-1"
  }
}
variable "environment" {
  default = "staging"
}

