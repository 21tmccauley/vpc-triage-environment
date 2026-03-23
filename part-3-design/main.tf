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
# Part 3: Students implement the network resources and tests.
# ------------------------------------------------------------------------------

# Example Terraform Syntax
#
# resource "aws_vpc" "main_vpc" {
#   cidr_block = "10.0.0.0/16"
# }
#
# resource "aws_internet_gateway" "main_igw" {
#   vpc_id = aws_vpc.main_vpc.id
# }
#
# resource "aws_subnet" "web_subnet" {
#   vpc_id     = aws_vpc.main_vpc.id
#   cidr_block = "10.0.1.0/24"
# }
#
# resource "aws_subnet" "app_subnet" {
#   vpc_id     = aws_vpc.main_vpc.id
#   cidr_block = "10.0.2.0/24"
# }
#
# resource "aws_subnet" "db_subnet" {
#   vpc_id     = aws_vpc.main_vpc.id
#   cidr_block = "10.0.3.0/24"
# }
#
# resource "aws_route_table" "web_rt" { vpc_id = aws_vpc.main_vpc.id }
# resource "aws_route_table" "app_rt" { vpc_id = aws_vpc.main_vpc.id }
# resource "aws_route_table" "db_rt"  { vpc_id = aws_vpc.main_vpc.id }
#
# resource "aws_route_table_association" "web_assoc" {
#   subnet_id      = aws_subnet.web_subnet.id
#   route_table_id = aws_route_table.web_rt.id
# }
#
# resource "aws_route_table_association" "app_assoc" {
#   subnet_id      = aws_subnet.app_subnet.id
#   route_table_id = aws_route_table.app_rt.id
# }
#
# resource "aws_route_table_association" "db_assoc" {
#   subnet_id      = aws_subnet.db_subnet.id
#   route_table_id = aws_route_table.db_rt.id
# }
