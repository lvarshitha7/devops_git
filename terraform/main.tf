provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-05d2d839d4f73aafb"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-ec2"
  }
}