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

#Assignment 9
locals {
  all_locations = concat(var.user_locations, var.default_locations)
  unique_locations = toset(local.all_locations)
}

output "names_of_all_locations" {
  value = local.all_locations
}
output "unique_locations" {
  value = local.unique_locations
  
}


variable "monthly_costs" {
  default = [-50, 100, 75, 200]  # -50 is a credit
}
locals {
  positive_costs = [for cost in var.monthly_costs : abs(cost)]
  max_cost       = max(local.positive_costs...)
  total_cost     = sum(local.positive_costs)
  avg_cost       = local.total_cost / length(local.positive_costs)
}

output "max_cost" {
  value = local.max_cost
}
output "total_cost" {
  value = local.total_cost
}
output "positive_costs" {
  value = local.positive_costs
}


#ASSginment 12
locals {
  config_file_exist = fileexists("config.json")
  config_file_content = local.config_file_exist ? jsondecode(file("config.json")) : {}
}

output "name_of_config_file_exist" {
  value = local.config_file_exist
  # if file exits then true else false
}
output "name_of_config_file_content" {
  value = local.config_file_content
}