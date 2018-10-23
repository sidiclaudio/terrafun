#AUTHOR: Claudio Sidi
#VERSION: Terraform v0.11.9 + provider.aws v1.41.0
#FILE: terraform.tfvars
aws_profile		= "default"
aws_region		= "us-east-1"
vpc_cidr      = "10.0.0.0/16"
localip = "your local IP/32"
dev_instance_type	= "t2.micro"
dev_ami			= "ami-40d28157"
cidrs			= {
  public1  = "10.0.1.0/24"
}
key_name		= "yourkey"
public_key_path		= "/path/.ssh/yourkey.pub"
