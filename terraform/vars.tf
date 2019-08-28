#List of varaibles

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "aws_region" {
	default = "us-east-1"
}
variable "base_cidr_block" {
	description = "A /16 CIDR range definition, such as 10.0.0.0/16, that the VPC will use"
	default = "10.0.0.0/16"
}
variable "availability_zones" {
	description = "A list of availability zones in which to create subnets"
	default = ["us-east-1a","us-east-1b","us-east-1c"]
}
