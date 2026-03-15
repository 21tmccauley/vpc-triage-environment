# ------------------------------------------------------------------------------
# Provider Configuration (Configured for LocalStack)
# ------------------------------------------------------------------------------
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"

  # Crucial settings to force Terraform to use LocalStack instead of real AWS
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

# ------------------------------------------------------------------------------
# Core Networking Infrastructure (Starter Code)
# ------------------------------------------------------------------------------

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab-vpc"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "lab-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-public-subnet"
  }
}

# ==============================================================================
# INTENTIONAL BUG BELOW:
# The route table is created, but it lacks the actual route to the Internet Gateway.
# ==============================================================================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  # Students will need to add the following block to fix the tests:
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.main_igw.id
  # }

  tags = {
    Name = "lab-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
