#Terraform configuration to deploy a custom vpc with 2 subnets 
# in 1 Availability zone in AWS
#Copyright: gb@zack
#---------------

resource "aws_vpc" "vpc" {
	instance_tenancy =  "default"

	# Referencing the base_cidr_block variable allows the network address
	# to be changed without modifying the configuration	
	cidr_block = "${var.base_cidr_block}"
	tags = {
		Name = "VPC"
	}
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
	cidr_block = "${cidrsubnet("${aws_vpc.vpc.cidr_block}",4,4)}"
	map_public_ip_on_launch = true
	tags = {
		Name = "publicA"
	}
}

resource "aws_subnet" "privateA" {
	availability_zone = "${var.availability_zones[1]}"
	vpc_id = "${aws_vpc.vpc.id}"
	cidr_block = "${cidrsubnet("${aws_vpc.vpc.cidr_block}",4,5)}"
	map_public_ip_on_launch = false
	tags = {
		Name = "privateA"
	}
}

resource "aws_eip" "eip" {
	vpc = true
	tags = {
		Name = "EIP"
	}
	depends_on = ["aws_internet_gateway.InternetGateway"]
}

resource "aws_nat_gateway" "Natgateway" {
	allocation_id = "${aws_eip.eip.id}"
	subnet_id = "${aws_subnet.publicA.id}"
	tags = {
		Name = "Ngw"
	}
}

#Public routable configurations
resource "aws_route_table" "publicRouteTable" {
	vpc_id = "${aws_vpc.vpc.id}"
	tags = {
		Name = "publicRouteTable"
	}
}

resource "aws_route" "publicRoute" {
	route_table_id = "${aws_route_table.publicRouteTable.id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.InternetGateway.id}"
	depends_on = ["aws_route_table.publicRouteTable"]
}

resource "aws_route_table_association" "plublicRouteAssociation" {
	subnet_id = "${aws_subnet.publicA.id}"
	route_table_id = "${aws_route_table.publicRouteTable.id}"
}

#Private routable configurations
resource "aws_route_table" "privateRouteTable" {
	vpc_id = "${aws_vpc.vpc.id}"
	tags = {
		Name = "privateRouteTable"
	}
}

resource "aws_route" "privateRoute" {
	route_table_id = "${aws_route_table.privateRouteTable.id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_nat_gateway.Natgateway.id}"
	depends_on = ["aws_route_table.privateRouteTable"]
}

resource "aws_route_table_association" "privateRouteAssociation" {
	subnet_id = "${aws_subnet.privateA.id}"
	route_table_id = "${aws_route_table.privateRouteTable.id}"
}

#Public Network ACL configurations
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
	protocol = -1
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

#Private Network ACL configurations
resource "aws_network_acl" "privateNACL" {
	vpc_id = "${aws_vpc.vpc.id}"
	
	tags = {
		Name = "privateNACL"
	}
}

resource "aws_network_acl_rule" "private_nacl_ruleIn" {
	network_acl_id = "${aws_network_acl.privateNACL.id}"
	rule_number = 100
	egress = false
	protocol = -1
	rule_action = "deny"
	cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "private_nacl_ruleOut" {
	network_acl_id = "${aws_network_acl.privateNACL.id}"
	rule_number = 100
	egress = true
	protocol = -1
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
}
