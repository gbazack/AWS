#Terraform configuration to deploy a custom vpc with 2 subnets 
# in 1 Availability zone in AWS
#Copyright: gb@zack
#---------------

resource "aws_vpc" "vpc" {
	instance_tenancy =  "default"

	# Referencing the base_cidr_block variable allows the network address
	# to be changed without modifying the configuration	
	cidr_block = "${var.base_cidr_block}"
}

resource "aws_internet_gateway" "InternetGateway" {
	vpc_id = "${aws_vpc.vpc.id}"
	tags = {
		Name = "Igw"
	}
}

resource "aws_subnet" "publicA" {
	availability_zone = "${var.availability_zones[1]}"
	vpc_id = "${aws_vpc.vpc.id}"
	cidr_block = "${cidrsubnet("10.0.0.0/16",2,1)}"
	map_public_ip_on_launch = true
	tags = {
		Name = "publicA"
	}
}

resource "aws_route_table" "publicRouteTable" {
	vpc_id = "${aws_vpc.vpc.id}"
	tags = {
		Name = "publicRouteTable"
	}
}

resource "aws_egress_only_internet_gateway" "egress" {
	vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "publicRoute" {
	route_table_id = "${aws_route_table.publicRouteTable.id}"
	destination_cidr_block = "0.0.0.0/0"
	depends_on = ["aws_route_table.publicRouteTable"]
}

resource "aws_route_table_association" "plublicRouteAssociation" {
	subnet_id = "${aws_subnet.publicA.id}"
	route_table_id = "${aws_route_table.publicRouteTable.id}"
}

resource "aws_network_acl" "publicNACL" {
	vpc_id = "${aws_vpc.vpc.id}"
	
	tags = {
		Name = "publicNACL"
	}
}

resource "aws_network_acl_rule" "nacl_ruleIn" {
	network_acl_id = "${aws_network_acl.publicNACL.id}"
	rule_number = 100
	egress = false
	protocol = "all"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "nacl_ruleOut" {
	network_acl_id = "${aws_network_acl.publicNACL.id}"
	rule_number = 100
	egress = true
	protocol = -1
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
}
