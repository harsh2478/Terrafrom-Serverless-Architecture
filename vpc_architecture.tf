resource "aws_vpc" "vpc"{
        cidr_block = "192.168.0.0/16"

        tags = {
                Name = "Terraform_VPC"
        }
}

resource "aws_subnet" "public_subnets" {
        count = length(var.public_subnet_cidrs)
        vpc_id = aws_vpc.vpc.id
        availability_zone = element(var.aws_azs, count.index)
        cidr_block = element(var.public_subnet_cidrs, count.index)

        tags = {
                Name = "public_subnet- ${count.index + 1}"
        }
}

resource "aws_subnet" "private_subnets" {
        count = length(var.private_subnet_cidrs)
        vpc_id = aws_vpc.vpc.id
        availability_zone = element(var.aws_azs, count.index)
        cidr_block = element(var.private_subnet_cidrs, count.index)
        tags = {
                Name = "private-subnet- ${count.index + 1}"
        }
}

resource "aws_internet_gateway" "igw" {
        vpc_id = aws_vpc.vpc.id
        tags = {
                Name = "terrform-vpc-igw"
        }
}

resource "aws_route_table" "public_rt" {
        vpc_id = aws_vpc.vpc.id
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = aws_internet_gateway.igw.id
        }

        tags = {
                Name = "Public-route-table"
        }
}

resource "aws_route_table_association" "public-subnets-asso" {
        count = length(var.public_subnet_cidrs)
        subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
        route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "sg" {
        name = "terraform_sg"
        description = "This security group is for terraform practice"
        vpc_id = aws_vpc.vpc.id

        tags = {
                Name = "terraform_vg"
        }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
        security_group_id = aws_security_group.sg.id
        cidr_ipv4 = "0.0.0.0/0"
        from_port = 80
        ip_protocol = "tcp"
        to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_443" {
        security_group_id = aws_security_group.sg.id
        cidr_ipv4 = "0.0.0.0/0"
        from_port = 443
        ip_protocol = "tcp"
        to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_22" {
        security_group_id = aws_security_group.sg.id
        cidr_ipv4 = "0.0.0.0/0"
        from_port = 22
        ip_protocol = "tcp"
        to_port = 22
}


resource "aws_vpc_security_group_egress_rule" "egress_rule" {
        security_group_id = aws_security_group.sg.id
        cidr_ipv4         = "0.0.0.0/0"
        ip_protocol       = "-1" # semantically equivalent to all ports
}
