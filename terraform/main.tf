terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
  }
  backend "s3" {
    bucket       = "test-terraform-mhiaghi"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source      = "./modules/network"
  name        = "webpage"
  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.1.0/24"
}


resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_security_group" "sg" {
  name   = "lab-sg"
  vpc_id = module.network.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_instance" "vm" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t3.micro"
  subnet_id              = module.network.subnet_id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y docker.io
              apt-get install -y docker-compose-plugin
              systemctl start docker
              systemctl enable docker
              snap install amazon-ssm-agent --classic
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              mkdir /app
              EOF
  tags = {
    Name = "tf-lab"
  }
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.name
}

resource "aws_eip_association" "eip_vm" {
  instance_id   = aws_instance.vm.id
  allocation_id = aws_eip.eip.id
}

output "instance_id" {
  value = aws_instance.vm.id
}