

# Create a simple S3 bucket
# resource "aws_s3_bucket" "first_bucket" {
#   #   bucket = local.bucket_name_locals  // Using local variable
#   bucket = var.bucket_name // Using variable directly or tfvars value 
#   tags = {
#     Name = "My bucket"
#   }
#   # lifecycle {
#   #   prevent_destroy = true
#   # }
# }

# resource "aws_instance" "example" {
#   # count = 1
#   ami = "ami-0360c520857e3138f"
#   instance_type = "t2.micro"
#   associate_public_ip_address = var.associate_public_ip_address
#   key_name = "vmtest" #Accessing object type variable attribute
#   # tags = {
#   #   Name = "HelloWorld"  #This whole tag is a map type variable
#   # }
#   tags = var.tags
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic and all outbound traffic"
#   # vpc_id      = aws_vpc.main.id

#   # tags = {
#   #   Name = "allow_tls"
#   # }
#   # tags = var.tags
#   tags = {
#    Environment = var.environment
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv4 = var.allowed_cidr_block[1]
#   # cidr_ipv4         = tolist(var.allowed_cidr_block)[0] #If using set type variable we need to convert it to list to access by index
#   from_port         = var.sg[0]
#   ip_protocol       = var.sg[1]
#   to_port           = var.sg[2] 
# }


# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# resource "aws_security_group" "app_sg" {
#   name        = "app-security-groups"
#   description = "Security group for application servers"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow HTTP from anywhere"
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow HTTPS from anywhere"
#   }
#     ingress {
#     from_port   = 8000
#     to_port     = 8000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow HTTP from anywhere"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outbound traffic"
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "App Security Group"
#       Demo = "replace_triggered_by"
#     }
#   )
# }

# # EC2 Instance that gets replaced when security group changes
# resource "aws_instance" "app_with_sg" {
#   ami                    = "ami-0360c520857e3138f"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.app_sg.id]

#   tags = merge(
#     var.tags,
#     {
#       Name = "App Instance with Security Group"
#       Demo = "replace_triggered_by"
#     }
#   )

#   # Lifecycle Rule: Replace instance when security group changes
#   # This ensures the instance is recreated with new security rules
#   lifecycle {
#     replace_triggered_by = [
#       aws_security_group.app_sg.id
#     ]
#   }
# }



resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliance-bucket-for-testing-lifecycle-rules"

  tags = var.tags

  # Lifecycle Rule: Validate bucket has required tags after creation
  # This ensures compliance with organizational tagging policies
  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "ERROR: Bucket must have a 'Compliance' tag for audit purposes!"
    }

    postcondition {
      condition     = contains(keys(self.tags), "Environment")
      error_message = "ERROR: Bucket must have an 'Environment' tag!"
    }
  }
}
