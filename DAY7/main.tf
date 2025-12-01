

# # Create a simple S3 bucket
# resource "aws_s3_bucket" "first_bucket" {
#   #   bucket = local.bucket_name_locals  // Using local variable
#   bucket = var.bucket_name // Using variable directly or tfvars value 
#   tags = {
#     Name = "My bucket"
#   }
# }

resource "aws_instance" "example" {
  count = 1
  ami = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
  associate_public_ip_address = var.associate_public_ip_address
  key_name = var.config.key_name #Accessing object type variable attribute
  # tags = {
  #   Name = "HelloWorld"  #This whole tag is a map type variable
  # }
  tags = var.tags
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  # vpc_id      = aws_vpc.main.id

  # tags = {
  #   Name = "allow_tls"
  # }
  # tags = var.tags
  tags = {
   Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = var.allowed_cidr_block[1]
  # cidr_ipv4         = tolist(var.allowed_cidr_block)[0] #If using set type variable we need to convert it to list to access by index
  from_port         = var.sg[0]
  ip_protocol       = var.sg[1]
  to_port           = var.sg[2] 
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

