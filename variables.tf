#AUTHOR: Claudio Sidi
#VERSION: Terraform v0.11.9 + provider.aws v1.41.0
#FILE: terraform.tfvars

#DEFINE ALL MY VARIABLES
variable "aws_region" {}
variable "aws_profile" {}
variable "key_name" {}
variable "public_key_path" {}
data "aws_availability_zones" "available" {}
variable "localip" {}
variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}
variable "dev_instance_type" {}
variable "dev_ami" {}
