# Terraform & Provider

terraform {
  required_version = "> 1.5.0"

  required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}







#################################
# SSH Key generation
## SSH key generation with Teraform

# resource "tls_private_key" "ssh_key" {
#  algorithm = "RSA"
#  rsa_bits = 4096
#}

## Record the public key in AWS

# resource "aws_key_pair" "ec2_key" {
#  key_name   = "terraform-ec2-key"
#  public_key = tls_private_key.ssh_key.public_key_openssh
#}

##################################
# Security Group

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-no-ingress" 
  description = "No inbound traffic allowed"
  vpc_id      = data.aws_vpc.default.id


  tags = {
   Name = "terraform-ec-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.ec2_sg.id  
   
   protocol = "-1"
   cidr_ipv4 = "0.0.0.0/0"
 }


##################################
# Instance EC2 #

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
  name = "name"
  values = ["al2023-ami-*x86_64"]
  }

  filter {
  name = "virtualization-type"
  values = ["hvm"]
  }

owners = ["amazon"]
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2_key.key_name

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  tags = {
    Name = "terraform-ec2-demo"
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true



  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "Hello from EC2 DevOps" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name = "ec2-devops-exo"
  }
}
