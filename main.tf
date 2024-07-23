terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }

  backend "s3" {
    bucket= "tf-bucket75"
    key= "terraform.tfstate"
    region= "ap-south-1"
    dynamodb_table = "tfdynamo"    #It is used to apply state locking mechanism
  }
}

provider "aws" {
  region = "ap-south-1"
  #   access_key = ""
  #   secret_key = ""
}

#Create the VPC
resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

module "subnetFunction" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myvpc.id
  subnet_cidr_block = var.subnet_cidr_block
}

module "webserverFunction" {
  source = "./modules/webserver"
  subnet_id = module.subnetFunction.subnet.id
  instance_type = var.instance_type
  vpc_id = aws_vpc.myvpc.id
}
