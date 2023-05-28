terraform {
  # cloud {
  #   organization = "test-zlh"

  #   workspaces {
  #     name = "test"
  #   }
  # }

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
  access_key = "AKIA5VS63UOQ5GSJYTZQ"
  secret_key = "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"
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
              sudo apt-get update -y
              sudo apt-get install \
                git \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg-agent \
                software-properties-common -y
              
              "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
              sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'
              sudo apt-get update
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              sudo systemctl status docker

              cd /home/ubuntu
              git clone https://github.com/ZihaoLiu0927/python_web_dev.git > /tmp/git_clone_output.txt 2>&1
              cd python_web_dev

              docker pull mysql
              docker run \
                --name mysql \
                -v /Users/zach/Downloads/mysqldb:/var/lib/ \
                --network mynetwork \
                -p 3306:3306 \
                -e MYSQL_ROOT_PASSWORD=123456 \
                -d mysql
              
              cat www/schema.sql | docker exec -i mysql mysql -u root -p123456

              docker build -t my-python-app .
              docker run --name my-python-app --network
              mynetwork -p 8080:8080 -d my-python-app
              EOF

  tags = {
    Name = "blog"
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}

