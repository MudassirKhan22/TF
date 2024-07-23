output "ec2_public_ip" {
  value = module.webserverFunction.ec2.public_ip
}

output "ami_id" {
  value =  module.webserverFunction.ec2.ami
}