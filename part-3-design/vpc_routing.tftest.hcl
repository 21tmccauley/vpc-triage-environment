# Part 3 test file
# Write your own run blocks and assertions to verify:
# - web_rt has default route to IGW
# - app_rt has default route to IGW
# - db_rt does NOT have a default route
# - each subnet is associated with the correct route table

# Example test syntax
#
# run "verify_web_routing" {
#   command = apply
#
#   assert {
#     condition     = length([for r in aws_route_table.web_rt.route : r if r.cidr_block == "0.0.0.0/0"]) > 0
#     error_message = "ROUTING ERROR: web_rt missing default route."
#   }
# }
