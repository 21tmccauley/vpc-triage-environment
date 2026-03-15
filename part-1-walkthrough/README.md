# Part 1: Walkthrough — Single Public Subnet

This is the **guided** part of the lab. Follow the instructions and the walkthrough to fix a broken VPC configuration.

## What you're building

- One VPC (10.0.0.0/16)
- One public subnet (10.0.1.0/24)
- An Internet Gateway and a route table for the subnet
- **Problem:** The route table is missing the default route to the Internet Gateway, so the subnet has no path to the internet.

## Instructions

1. **Start LocalStack** (from the repo root, if not already running):
   ```bash
   docker compose up -d
   ```

2. **Open this directory** and run Terraform:
   ```bash
   cd part-1-walkthrough
   terraform init
   terraform test
   ```

3. **Expect the tests to fail** the first time. Read the error messages; they tell you what is wrong.

4. **Fix the configuration** in `main.tf` using the test output and the [Walkthrough](WALKTHROUGH.md) if you need step-by-step help.

5. **Re-run the tests** until you see all runs pass and **Success!** at the end.

## Expected output when you first run the tests

You should see one run fail and one pass. The failure messages are what you use to fix the config:

```
vpc_routing.tftest.hcl... in progress
  run "verify_public_routing"... fail
╷
│ Error: Test assertion failed
│   on vpc_routing.tftest.hcl line 10, in run "verify_public_routing":
│   10:     condition     = length(aws_route_table.public_rt.route) > 0
│
│ NETWORK OUTAGE: The public route table is empty. Without routes, subnets associated with this table cannot communicate out.
╵
╷
│ Error: Test assertion failed
│   on vpc_routing.tftest.hcl line 16, in run "verify_public_routing":
│   16:     condition     = length([for r in aws_route_table.public_rt.route : r if r.cidr_block == "0.0.0.0/0"]) > 0
│
│ ROUTING ERROR: The route table is missing a default route (0.0.0.0/0) pointing to the Internet Gateway.
╵
  run "verify_subnet_association"... pass
vpc_routing.tftest.hcl... tearing down
vpc_routing.tftest.hcl... fail

Failure! 1 passed, 1 failed.
```

Use these messages to find the problem in `main.tf` and add the missing route.

## Need more help?

- **[WALKTHROUGH.md](WALKTHROUGH.md)** — Step-by-step guide with the fix explained.
- **[/CONCEPTS.md](../CONCEPTS.md)** (in repo root) — How Terraform, AWS services, and VPC networking work.
