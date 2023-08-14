terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 4.16"
    }
  }
  
  backend "s3" {
    bucket         = "devops-directive-tf-state-00001"
    key            = "03-basics/import-bootstrap/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "ec2_example" {
  ami             = "ami-02a89066c48741345"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  tags = {
    Name = "instance 1"
  }
  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world 1" > index.html
        python3 -m http.server 8080 &
        EOF
}

resource "aws_instance" "ec2_example2" {
  ami             = "ami-02a89066c48741345"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  tags = {
    Name = "instance 2"
  }
  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world 2" > index.html
        python3 -m http.server 8080 &
        EOF
}


data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_security_group" "instances" {
  name        = "instance-security-group"
  description = "Allow https to web server"
  vpc_id      = data.aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id
  from_port   = 8080
  to_port     = 8080
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instances.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
