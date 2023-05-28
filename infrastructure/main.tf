terraform {
  cloud {
    organization = "test-zlh"

    workspaces {
      name = "test"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "sg" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // replace this with your IP address for security
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              export ENVIRONMENT="production"
              export MYSQL_ROOT_PASSWORD="${var.mysql_root_password}"
              export DB_PASSWORD=$MYSQL_ROOT_PASSWORD
              sudo apt-get update -y
              sudo apt-get install -y python3-pip git apache2
              cd /home/ubuntu
              git clone https://github.com/ZihaoLiu0927/python_web_dev.git > /tmp/git_clone_output.txt 2>&1
              cd python_web_dev
              pip3 install -r requirements.txt
              echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
              echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
              sudo apt-get install -y mysql-server
              mysql -u root -p$MYSQL_ROOT_PASSWORD < www/schema.sql
              echo $MYSQL_ROOT_PASSWORD >> /tmp/password.txt
              echo $MYSQL_ROOT_PASSWORD >> /tmp/password.txt
              echo $ENVIRONMENT >> /tmp/password.txt
              echo $DB_PASSWORD >> /tmp/password.txt
              sudo python3 www/app.py > /tmp/app_output.txt 2>&1 &
              EOF

  tags = {
    Name = "blog"
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}

