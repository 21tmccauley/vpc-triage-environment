# vpc_routing.tftest.hcl

run "verify_public_routing" {
  command = plan

  # Assertion 1: Check if ANY routes exist in the route table
  assert {
    condition     = length(aws_route_table.public_rt.route) > 0
    error_message = "NETWORK OUTAGE: The public route table is empty. Without routes, subnets associated with this table cannot communicate out."
  }

  # Assertion 2: Check specifically for the 0.0.0.0/0 default route
  assert {
    condition     = length([for r in aws_route_table.public_rt.route : r if r.cidr_block == "0.0.0.0/0"]) > 0
    error_message = "ROUTING ERROR: The route table is missing a default route (0.0.0.0/0) pointing to the Internet Gateway."
  }
}

run "verify_subnet_association" {
  command = plan

  # Assertion 3: Ensure the subnet is actually attached to the route table
  assert {
    condition     = aws_route_table_association.public_assoc.subnet_id == aws_subnet.public_subnet.id
    error_message = "ASSOCIATION ERROR: The public subnet is not associated with the correct route table."
  }
}