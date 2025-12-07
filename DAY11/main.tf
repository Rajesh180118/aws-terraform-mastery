#Assignment 1
locals {
  project_name = replace(lower(var.project_name), " ", "-")
}
# output "ASG1" {
#     value=local.project_name
# }

#Assignment 2
locals{
  merged_tags = merge(var.default_tags, var.environment_tags)
}

# resource "aws_s3_bucket" "example" {
#     bucket = "example-bucket-${local.project_name}"
#     tags = local.merged_tags
  
# }
# output "ASG2" {
#   value=aws_s3_bucket.example.tags
# }

#Assignment 3
locals {
    bucket_name_formatted = substr(replace(lower(var.bucket_name), " ", "-"), 0, 63)
}
# resource "aws_s3_bucket" "example" {
#     bucket = local.bucket_name_formatted
#     tags   = local.merged_tags
# }
# output "ASG3" {
# #   value = aws_s3_bucket.example.bucket
#   value = local.bucket_name_formatted
# }

#Assignment 4
# locals {
#   port_list = split(",", var.allowed_ports)
#   sg_rules= [for port in local.port_list: {
#     name = "allow_port_${port}"
#     port= port
#     protocol = "tcp"
#   }]
#   formatted_ports = join("-", [for port in local.port_list : "port-${port}"])

# }
# output "ASG4" {
#   value = local.formatted_ports
# }

#Assignment 5
locals {
    instance_region = lookup(var.instance_region, var.environment, "us-east-1")
}
output "ASG5" {
  value = local.instance_region
}