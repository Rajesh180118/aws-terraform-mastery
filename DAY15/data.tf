data "aws_availability_zones" "primary" {
  state = "available"
  provider = aws.primary
}

data "aws_availability_zones" "secondary" {
  state = "available"
  provider = aws.secondary
}

data "aws_ami" "example-primary" {
  provider =  aws.primary
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "example-secondary" {
  provider = aws.secondary
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
}

data "aws_caller_identity" "current" {}