# vpc_routing.tftest.hcl — Part 2: public + internal subnets, both need correct routing

run "verify_public_routing" {
  command = apply

  assert {
    condition     = length(aws_route_table.public_rt.route) > 0
    error_message = "NETWORK OUTAGE: The public route table has no routes. The public subnet cannot reach the internet."
  }

  assert {
    condition     = length([for r in aws_route_table.public_rt.route : r if r.cidr_block == "0.0.0.0/0"]) > 0
    error_message = "ROUTING ERROR: The public route table is missing a default route (0.0.0.0/0) to the Internet Gateway."
  }
}

run "verify_internal_routing" {
  command = apply

  assert {
    condition     = length(aws_route_table.internal_rt.route) > 0
    error_message = "NETWORK OUTAGE: The internal route table is empty. The internal subnet has no path for outbound traffic."
  }

  assert {
    condition     = length([for r in aws_route_table.internal_rt.route : r if r.cidr_block == "0.0.0.0/0"]) > 0
    error_message = "ROUTING ERROR: The internal route table is missing a default route (0.0.0.0/0). Add a route to the Internet Gateway so the internal subnet can reach the internet."
  }
}

run "verify_subnet_associations" {
  command = apply

  assert {
    condition     = aws_route_table_association.public_assoc.subnet_id == aws_subnet.public_subnet.id
    error_message = "ASSOCIATION ERROR: The public subnet is not associated with the public route table."
  }

  assert {
    condition     = aws_route_table_association.internal_assoc.subnet_id == aws_subnet.internal_subnet.id
    error_message = "ASSOCIATION ERROR: The internal subnet is not associated with the internal route table."
  }
}
