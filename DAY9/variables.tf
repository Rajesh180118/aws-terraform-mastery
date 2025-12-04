variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "mys3bucketbyraja1801testingvariable"

}
variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "Development"
  
}
variable "random_suffix" {
  description = "Random suffix to ensure unique bucket name"
  type        = string
  default     = "001"
}



variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "allowed_cidr_block" {
  description = "CIDR block allowed to access the security group"
  type        = list(string)
  default     = ["10.0.0.0/16","172.1.0.0/24"]
}
# variable "allowed_cidr_block" {
#   description = "CIDR block allowed to access the security group"
#   type        = set(string)
#   default     = ["10.0.0.0/16","172.1.0.0/24"]
# }

#Map type variable for tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "Development"
    Project     = "TerraformDemo"
  }
}

#Tuple type variable
 variable "sg"{
  description = "CIDR block allowed to access the security group"
  type        = tuple([number,string,number])
  default     = [443,"tcp",443]
}

#Object type variable
variable "config" {
  description = "Configuration object"
  type = object({
    instance_type = string
    associate_public_ip_address = bool
    key_name      = string
  })
  default = {
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name      = "test"
  }
}