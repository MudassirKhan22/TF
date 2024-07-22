#!/bin/bash
# Debug information
echo "Starting user data script" > /tmp/user-data.log

sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
docker run -itd -p 8080:80 nginx