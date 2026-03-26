terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source      = "./modules/network"
  name        = "mhiaghi"
  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.1.0/24"
}

variable "ssh_ips" {
  default = ["38.25.26.155/32"]
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
  tags = {
    Name = "tf-lab"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "tf-key"
  public_key = file("my-key.pub")
}

resource "aws_eip_association" "eip_vm" {
  instance_id   = aws_instance.vm.id
  allocation_id = aws_eip.eip.id
}

output "elastic_ip" {
  value = aws_eip.eip.public_ip
}