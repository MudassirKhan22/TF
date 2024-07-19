terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
#   access_key = ""
#   secret_key = ""
}


variable "instance_type" {}

resource "aws_instance" "web" {
  count = 2
  ami           = "ami-0d1e92463a5acf79d"
  instance_type = var.instance_type

  tags = {
    Name = "${terraform.workspace}-${count.index}"
  }
}