resource "aws_vpc" "primary" {
  cidr_block = var.primary_cidr_block
  provider   = aws.primary
   enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.primary_tags
}

resource "aws_vpc" "secondary" {
  cidr_block = var.secondary_cidr_block
  provider   = aws.secondary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.secondary_tags
}

resource "aws_subnet" "primary_subnet" {
  vpc_id     = aws_vpc.primary.id
  provider = aws.primary  
  cidr_block = var.primary_cidr_block   
  availability_zone = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-primary-region-subnet ${var.primary_region}"
  }
}
resource "aws_subnet" "secondary_subnet" {
  vpc_id     = aws_vpc.secondary.id
  provider = aws.secondary  
  cidr_block = var.secondary_cidr_block   
  availability_zone = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-secondary-region-subnet ${var.secondary_region}"
  }
}

resource "aws_internet_gateway" "gw-primary" {
  vpc_id = aws_vpc.primary.id
  provider = aws.primary
  tags = {
    Name = "terraform-primary-igw"
  }
}
resource "aws_internet_gateway" "gw-secondary" {
  vpc_id = aws_vpc.secondary.id
  provider = aws.secondary  
  tags = {
    Name = "terraform-secondary-igw"
  }
}
resource "aws_route_table" "rt-primary" {
  vpc_id = aws_vpc.primary.id
  provider = aws.primary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-primary.id
  }

  tags = {
    Name = "terraform-primary-rt"
  }
}
resource "aws_route_table" "rt-secondary" {
  vpc_id = aws_vpc.secondary.id
  provider = aws.secondary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-secondary.id
  }

  tags = {
    Name = "terraform-secondary-rt"
  }
}

resource "aws_route_table_association" "a-primary" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.rt-primary.id
  provider = aws.primary  
}
resource "aws_route_table_association" "a-secondary" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.rt-secondary.id
  provider = aws.secondary  
}

resource "aws_security_group" "primary-sg" {
  name   = "primary-sg"
  vpc_id = aws_vpc.primary.id
  provider = aws.primary

  ingress  {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "icmp"
    from_port = -1
    to_port   = -1
    cidr_blocks = [var.secondary_cidr_block]
  }

  ingress {
    protocol = "tcp"
    from_port = 0
    to_port   = 65535
    cidr_blocks = [var.secondary_cidr_block]
  }
  egress   {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
}

tags = {
    Name = "primary-sg-example"
  }
}

resource "aws_security_group" "secondary-sg" {
  name   = "sg"
  vpc_id = aws_vpc.secondary.id
  provider = aws.secondary

  ingress  {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "icmp"
    from_port = -1
    to_port   = -1
    cidr_blocks = [var.primary_cidr_block]
  }

  ingress {
    protocol = "tcp"
    from_port = 0
    to_port   = 65535
    cidr_blocks = [var.primary_cidr_block]
  }
  egress   {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
}

tags = {
    Name = "secondary-sg-example"
  }
}

resource "aws_vpc_peering_connection" "primary-to-secondary" {
  # peer_owner_id = var.peer_owner_id
  provider = aws.primary
  peer_vpc_id   = aws_vpc.secondary.id
  vpc_id        = aws_vpc.primary.id
  auto_accept   = false
  peer_region   = var.secondary_region

  tags = {
    Name = "VPC Peering between primary and secondary"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  # region                    = var.secondary_region
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-to-secondary.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "primary-to-secondary-route" {
  provider = aws.primary
  route_table_id            = aws_route_table.rt-primary.id
  destination_cidr_block    = var.secondary_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-to-secondary.id
    depends_on = [aws_vpc_peering_connection_accepter.peer]
}
resource "aws_route" "secondary-to-primary-route" {
  provider = aws.secondary
  route_table_id            = aws_route_table.rt-secondary.id
  destination_cidr_block    = var.primary_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary-to-secondary.id
  depends_on = [aws_vpc_peering_connection_accepter.peer]
}

resource "aws_instance" "primary-instance" {
  provider      = aws.primary
  ami           = data.aws_ami.example-primary.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.primary_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.primary-sg.id]
  tags = {
    Name = "TerraformInstance - Primary"
  }
   depends_on = [aws_vpc_peering_connection_accepter.peer]
}
resource "aws_instance" "secondary-instance" {
  provider      = aws.secondary
  ami           = data.aws_ami.example-secondary.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.secondary_subnet.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.secondary-sg.id]
  tags = {
    Name = "TerraformInstance - Secondary"
  }
 depends_on = [aws_vpc_peering_connection_accepter.peer]
}


resource "aws_s3_bucket" "primary_flowlog_s3_bucket" {
  bucket = var.s3_bucket_name_primary
  provider = aws.primary
}


resource "aws_s3_bucket_public_access_block" "example_primary" {
  bucket                  = aws_s3_bucket.primary_flowlog_s3_bucket.id
  provider = aws.primary
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy_primary" {
  bucket     = aws_s3_bucket.primary_flowlog_s3_bucket.id
  provider = aws.primary
  depends_on = [aws_s3_bucket_public_access_block.example_primary]

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSVPCFlowLogsWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.primary_flowlog_s3_bucket.arn}/AWSLogs/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    },
    {
      "Sid": "AWSVPCFlowLogsAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.primary_flowlog_s3_bucket.arn}"
    }
  ]
})
}


resource "aws_s3_bucket" "flowlog_s3_bucket_secondary" {
  bucket = var.s3_bucket_name_secondary
  provider = aws.secondary
}
resource "aws_s3_bucket_public_access_block" "example_secondary" {
  bucket                  = aws_s3_bucket.flowlog_s3_bucket_secondary.id
  provider = aws.secondary
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "bucket_policy_secondary" {
  bucket     = aws_s3_bucket.flowlog_s3_bucket_secondary.id
  provider = aws.secondary
  depends_on = [aws_s3_bucket_public_access_block.example_secondary]    
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSVPCFlowLogsWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.flowlog_s3_bucket_secondary.arn}/AWSLogs/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    },
    {
      "Sid": "AWSVPCFlowLogsAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.flowlog_s3_bucket_secondary.arn}"
    }
  ]
})
}

resource "aws_flow_log" "primary_vpc_flow_log" {
  provider = aws.primary
  log_destination      = aws_s3_bucket.primary_flowlog_s3_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.primary.id
  depends_on = [aws_instance.primary-instance]
}
resource "aws_flow_log" "secondary_vpc_flow_log" {
  provider = aws.secondary
  log_destination      = aws_s3_bucket.flowlog_s3_bucket_secondary.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.secondary.id
  depends_on = [aws_instance.secondary-instance]
}
