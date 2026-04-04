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

variable "ssh_ips" {
  default = ["38.25.17.187/32"]
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
  dynamic "ingress" {
    for_each = var.ssh_ips
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
}

resource "aws_instance" "vm" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = module.network.subnet_id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:80 --name nginx nginx
              EOF
  tags = {
    Name = "tf-lab"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "tf-key"
  public_key = var.public_key
}

resource "aws_eip_association" "eip_vm" {
  instance_id   = aws_instance.vm.id
  allocation_id = aws_eip.eip.id
}

output "elastic_ip" {
  value = aws_eip.eip.public_ip
}