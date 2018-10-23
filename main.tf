#AUTHOR: Claudio Sidi
#VERSION: Terraform v0.11.9 + provider.aws v1.41.0
#FILE: main.tf

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#-------------CREATING A VPC-----------

resource "aws_vpc" "terra_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "terra_vpc"
  }
}


#-----------Internet Gateway--------------

resource "aws_internet_gateway" "terra_internet_gateway" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  tags {
    Name = "terra_igw"
  }
}

#--------------Route tables----------------

resource "aws_route_table" "terra_public_rt" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_internet_gateway.id}"
  }

  tags {
    Name = "terra_public_rt"
  }
}

resource "aws_subnet" "terra_public1_subnet" {
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "terra_public1_sub"
  }
}

#-------------------Security groups-------------------------

resource "aws_security_group" "terra_dev_sg" {
  name        = "terra_dev_sg"
  description = "Used for access to our dev instance"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#-----------Subnet Associations---------------------------------------

resource "aws_route_table_association" "terra_public_assoc" {
  subnet_id      = "${aws_subnet.terra_public1_subnet.id}"
  route_table_id = "${aws_route_table.terra_public_rt.id}"
}

#key pair

resource "aws_key_pair" "terra_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# -----------------EC2 INSTANCE -----------------
resource "aws_instance" "terra_ec2" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"

  tags {
    Name = "terra_dev"
  }

  key_name               = "${aws_key_pair.terra_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.terra_dev_sg.id}"]
  #iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.terra_public1_subnet.id}"
}
