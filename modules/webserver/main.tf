#Create the security group
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Terraform SG"
  vpc_id      = var.vpc_id
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
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  associate_public_ip_address = true
  key_name = "Terraform_key"
  user_data = file("server-script.sh")


  tags = {
    Name = "Mywebserver"
  }
}

