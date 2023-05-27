terraform {
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
  region  = "us-east-1"
}

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
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y python3-pip git nginx
              git clone https://github.com/ZihaoLiu0927/python_web_dev.git
              cd python_web_dev
              pip3 install -r requirements.txt

              echo "mysql-server mysql-server/root_password password rootpassword" | sudo debconf-set-selections
              echo "mysql-server mysql-server/root_password_again password rootpassword" | sudo debconf-set-selections
              sudo apt-get install -y mysql-server
              mysql -u root -prootpassword < www/schema.sql

              python3 www/app.py > webapp.log 2>&1 &
              EOF

  tags = {
    Name = "myblog"
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
