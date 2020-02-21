provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}

##################################################################################
#
# Elastic IPs
#
##################################################################################
resource "aws_eip" "mongo_1" {
}

resource "aws_eip" "mongo_2" {
}

resource "aws_eip" "mongo_3" {
}

resource "aws_eip" "mongo_arbiter" {
}

locals {
  trusted_mongo = [
    "${aws_eip.mongo_1.public_ip}/32", 
    "${aws_eip.mongo_2.public_ip}/32",
    "${aws_eip.mongo_3.public_ip}/32",
    "${aws_eip.mongo_arbiter.public_ip}/32"
  ]
}

##################################################################################
#
# VPC and security group
#
##################################################################################
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "mongodb" {
  vpc_id = aws_default_vpc.default.id

  # allow all from Devops home
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.home_ip}/32"]
  }

  # allow 80 for letsencrypt (will be handled with firewalld)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow 443 for letsencrypt (will be handled with firewalld)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow monitoring port from all members to all members
  ingress {
    from_port   = 42000
    to_port     = 42005
    protocol    = "tcp"
    cidr_blocks = local.trusted_mongo
  }

  # allow monitoring server port from all members to all members
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = local.trusted_mongo
  }

  # allow 27017 from all members to all members
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = local.trusted_mongo
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##################################################################################
#
# Instances
#
##################################################################################
resource "aws_instance" "mongo_1" {

  ami = var.ami

  instance_type = var.mongo_instance_type

  tags = {
    Name = "mongo-1"
  }

  security_groups = [aws_security_group.mongodb.name]

  ebs_block_device {
    volume_size           = var.mongo_volume_size
    volume_type           = "gp2"
    delete_on_termination = true
    device_name           = "/dev/sdb"
    encrypted             = var.encrypt_mongo_volume
  }

  key_name = aws_key_pair.deployer.key_name
}

resource "aws_instance" "mongo_2" {

  ami = var.ami

  instance_type = var.mongo_instance_type

  tags = {
    Name = "mongo-2"
  }

  security_groups = [aws_security_group.mongodb.name]

  ebs_block_device {
    volume_size           = var.mongo_volume_size
    volume_type           = "gp2"
    delete_on_termination = true
    device_name           = "/dev/sdb"
    encrypted             = var.encrypt_mongo_volume
  }

  key_name = aws_key_pair.deployer.key_name
}

resource "aws_instance" "mongo_3" {

  ami = var.ami

  instance_type = var.mongo_instance_type

  tags = {
    Name = "mongo-3"
  }

  security_groups = [aws_security_group.mongodb.name]

  ebs_block_device {
    volume_size           = var.mongo_volume_size
    volume_type           = "gp2"
    delete_on_termination = true
    device_name           = "/dev/sdb"
    encrypted             = var.encrypt_mongo_volume
  }

  key_name = aws_key_pair.deployer.key_name
}

resource "aws_instance" "mongo_arbiter" {

  ami = var.ami

  instance_type = var.mongo_arbiter_instance_type

  tags = {
    Name = "mongo-arbiter"
  }

  security_groups = [aws_security_group.mongodb.name]

  ebs_block_device {
    volume_size           = var.mongo_arbiter_volume_size
    volume_type           = "gp2"
    delete_on_termination = true
    device_name           = "/dev/sdb"
    encrypted             = var.encrypt_mongo_volume
  }

  key_name = aws_key_pair.deployer.key_name
}

##################################################################################
#
# Use separate association as we need to declare eip in sg and sg in instances
#
##################################################################################
resource "aws_eip_association" "eip_assoc_mongo_1" {
  instance_id   = aws_instance.mongo_1.id
  allocation_id = aws_eip.mongo_1.id
}

resource "aws_eip_association" "eip_assoc_mongo_2" {
  instance_id   = aws_instance.mongo_2.id
  allocation_id = aws_eip.mongo_2.id
}

resource "aws_eip_association" "eip_assoc_mongo_3" {
  instance_id   = aws_instance.mongo_3.id
  allocation_id = aws_eip.mongo_3.id
}

resource "aws_eip_association" "eip_assoc_mongo_arbiter" {
  instance_id   = aws_instance.mongo_arbiter.id
  allocation_id = aws_eip.mongo_arbiter.id
}
