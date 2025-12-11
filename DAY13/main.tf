# variable "vpc_id" {}

data "aws_vpc" "selected" {
  # filter {
  #   name   = "tag:Name"
  #   values = ["myvpc"]
  # }
}
data "aws_security_group" "selected" {
  filter {
    name   = "tag:Name"
    values = ["terra"]
  }
  vpc_id = data.aws_vpc.selected.id
}

output "aws_sg" {
  value = data.aws_security_group.selected.id
}

data "aws_subnet" "test" {
  filter {
    name   = "tag:Name"
    values = ["terraform"]
  }
  vpc_id = data.aws_vpc.selected.id
}

output "id_vpc" {
  value = data.aws_vpc.selected.id
}

output "subnet_id" {
  value = data.aws_subnet.test.id
}


# data "aws_ami_ids" "ubuntu" {
#   owners = ["099720109477"]

#  filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
#   }
#     filter {
#     name   = "state"
#     values = ["available"]
#   }
# }

data "aws_ami" "example" {
  # executable_users = ["self"]
  most_recent      = true
  # name_regex       = "^myami-[0-9]{3}"
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  # filter {
  #   name   = "root-device-type"
  #   values = ["ebs"]
  # }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value = data.aws_ami.example.id
}
# output "name_of_config_file_containing_ami_ids" {
#   value = data.aws_ami_ids.ubuntu.ids
# }
resource "aws_instance" "testingdata_source" {
  ami           = data.aws_ami.example.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.test.id
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  tags = {
    Name = "TerraformInstance"
  }
  
}