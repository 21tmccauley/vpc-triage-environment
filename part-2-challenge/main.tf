# ------------------------------------------------------------------------------
# Provider Configuration (Configured for LocalStack)
# ------------------------------------------------------------------------------
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

# ------------------------------------------------------------------------------
# Part 2: VPC with Public and Internal Subnets
# Two subnets, two route tables. One has a routing problem.
# ------------------------------------------------------------------------------

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "part2-vpc"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "part2-igw"
  }
}

# Public subnet (10.0.1.0/24) — has its own route table with default route to IGW
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "part2-public-subnet"
  }
}

# Internal subnet (10.0.2.0/24) — should use internal_rt for outbound traffic
resource "aws_subnet" "internal_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "part2-internal-subnet"
  }
}

# Public route table — correctly has default route to IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "part2-public-rt"
  }
}

# Internal route table — INTENTIONAL BUG: missing default route to IGW
# The internal subnet needs outbound internet; this route table has no route for it.
resource "aws_route_table" "internal_rt" {
  vpc_id = aws_vpc.main_vpc.id

  # Students must add a default route here, e.g.:
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.main_igw.id
  # }

  tags = {
    Name = "part2-internal-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "internal_assoc" {
  subnet_id      = aws_subnet.internal_subnet.id
  route_table_id = aws_route_table.internal_rt.id
}
