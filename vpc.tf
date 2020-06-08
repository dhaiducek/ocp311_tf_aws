# Create a VPC
resource "aws_vpc" "ocp311" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-vpc"
    )
  )
}

# Create an Internet Gateway
resource "aws_internet_gateway" "ocp311" {
  vpc_id = aws_vpc.ocp311.id

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-internet-gateway"
    )
  )
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ocp311.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.zones.names[0]

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-public-subnet"
    )
  )
}

# Create a route table allowing all addresses access to the Internet Gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ocp311.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ocp311.id
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-public-route-table"
    )
  )
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public-subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create an Elastic IP for NAT gateway
resource "aws_eip" "natgateway_eip" {
    vpc      = true
    
    tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-nat-gateway-eip"
    )
  )
}

# Create the NAT gateway
resource "aws_nat_gateway" "private_natgateway" {
    allocation_id = aws_eip.natgateway_eip.id
    subnet_id = aws_subnet.public_subnet.id
    depends_on = [ aws_internet_gateway.ocp311 ]

    tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-private-nat-gateway"
    )
  )
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.ocp311.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = data.aws_availability_zones.zones.names[0]
 
  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-private-subnet"
    )
  )
}

# Create a route table allowing private subnet access to the NAT Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.ocp311.id
  route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.private_natgateway.id
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-private-route-table"
    )
  )
}

# Associate the route table with the private subnet
resource "aws_route_table_association" "private-subnet" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}