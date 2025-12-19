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

variable "regions" {
  default = ["us-east-1", "us-west-2", "us-east-2"]
  
}
variable "environment" {
  default = "staging"
}

#Assignment 6 Validation purpose 
variable "instance_type" {
  default     = "x4.micro"

  validation {
    condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 20
    error_message = "The instance_type must be 2 and 20 character ."
  }
  validation {
    condition= can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "must start with t2. or t3. "
  }
}

variable "region_with_validation" {
  default = "ue-east-1"

  validation {
    condition     = can(regex("^us\\-(east|west)\\-\\d+$", var.region_with_validation))
    error_message = "The region must be in the format 'us-east-1' or 'us-west-2'."
  }
  validation {
    condition = contains(var.regions, var.region_with_validation)
    error_message = "The region must be one of the allowed regions: us-east-1, us-east-2, us-west-1, us-west-2."
  }
   validation {
    condition     = length(var.region_with_validation) >= 2 && length(var.region_with_validation) <= 15
    error_message = "The region must be 2 and 15 character ."
  }

  validation {
    condition = startswith(var.region_with_validation, "us-")
    error_message = "The region must start with 'us-'."
  }

}

#Assiggnement 7
variable "backup"{
  default= "test_backup"

  validation {
    condition = endswith(var.backup, "_backup")
    error_message = "The backup name must end with '_backup'."
  }
}

variable "terraformfile_with_validation"{
  default= "main.tf"

  validation {
    condition = endswith(var.terraformfile_with_validation, ".tf") 
    error_message = "The terraform file name must end with '.tf'"
  }
  
}

variable "user_locations" {
  default = ["us-east-1", "us-west-2", "us-east-1"]  # Has duplicate
}

variable "default_locations" {
  default = ["us-west-1"]
}
