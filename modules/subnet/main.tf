#Create the subnet
resource "aws_subnet" "mysubnet" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "mysubnet"
  }
}

#Create the Internet Gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "myigw"
  }
}

#Create the Route table and add routes
resource "aws_route_table" "myrt" {
  vpc_id = var.vpc_id

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