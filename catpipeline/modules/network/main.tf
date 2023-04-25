data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

/* resource "aws_vpc_ipam" "catpipeline" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "catpipeline" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.catpipeline.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "catpipeline" {
  ipam_pool_id = aws_vpc_ipam_pool.catpipeline.id
  cidr         = "172.10.0.0/16"
} */

resource "aws_vpc" "catpipeline" {
  cidr_block = "172.10.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "catpipeline" {
  vpc_id = aws_vpc.catpipeline.id
}

resource "aws_route_table" "catpipeline" {
  vpc_id = aws_vpc.catpipeline.id
}

resource "aws_route" "catpipeline" {
  route_table_id            = aws_route_table.catpipeline.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.catpipeline.id
  depends_on                = [
    aws_internet_gateway.catpipeline,
    aws_vpc.catpipeline,
    ]
}

resource "aws_subnet" "catpipeline_primary" {
  vpc_id     = aws_vpc.catpipeline.id
  cidr_block = "172.10.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "catpipeline_secondary" {
  vpc_id     = aws_vpc.catpipeline.id
  cidr_block = "172.10.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "catpipeline" {
  subnet_id = aws_subnet.catpipeline_primary.id
  route_table_id = aws_route_table.catpipeline.id
  depends_on = [
    aws_route_table.catpipeline,
    aws_subnet.catpipeline_primary
  ]
}

resource "aws_security_group" "allow_ssh" {
  name        = "ilyass_allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.catpipeline.id

  ingress {
    description      = "TLS from home"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from home"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  depends_on = [
    aws_vpc.catpipeline
  ]
}