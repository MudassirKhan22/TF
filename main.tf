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
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

#Create the subnet
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mysubnet"
  }
}

#Create the Internet Gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

#Create the Route table and add routes
resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags= {
    Name: "own-rt"
  }
}

#Associate Route table with subnet
resource "aws_route_table_association" "myassociation" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt.id
}

#Create the security group
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Terraform SG"
  vpc_id      = aws_vpc.myvpc.id
  tags = {
    Name = "mysg"
  }
}

#Create the Security Group Ingress rule
resource "aws_vpc_security_group_ingress_rule" "HTTP" {
  security_group_id = aws_security_group.mysg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_ingress_rule" "SSH" {
  security_group_id = aws_security_group.mysg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

#Create the Security Group Egress rule
resource "aws_vpc_security_group_egress_rule" "my_eg" {
  security_group_id = aws_security_group.mysg.id

  cidr_ipv4   = "0.0.0.0/0"
  #from_port   = 0
  ip_protocol = -1
  #to_port     = 0
}


# variable "instance_type" {}

resource "aws_instance" "myinstance" {
  
  ami           = "ami-0d1e92463a5acf79d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  associate_public_ip_address = true
  key_name = "Terraform_key"
  user_data = file("server-script.sh")


  tags = {
    Name = "Mywebserver"
  }
}

