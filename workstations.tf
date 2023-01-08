terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu_lst" {
  most_recent = var.most_recent
  owners      = var.owners
  filter {
    name   = "name"
    values = var.name_filter
  }
  filter {
    name   = "virtualization-type"
    values = var.virtualization_type
  }
}

resource "aws_default_subnet" "az_1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.key_name
  public_key = file(var.public_key)
}

resource "aws_security_group" "workstations_sg" {
  name = var.sg_name
  dynamic "ingress" {
    for_each = var.open_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.sg_protocol
      cidr_blocks = var.all_addresses
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.all_addresses
  }
}

resource "aws_instance" "workstation" {
  count                  = var.number
  ami                    = data.aws_ami.ubuntu_lst.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.workstations_sg.id]
  subnet_id              = aws_default_subnet.az_1.id
  tags                   = merge(var.common_tags, { Name = format("Workstation-%d", count.index + 1) })
}
