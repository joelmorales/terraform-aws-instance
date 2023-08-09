terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

resource "aws_instance" "app_server" {
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

