# Part 2: Challenge — Public and App Subnets

This is the **challenge** part of the lab. There is no step-by-step walkthrough. Use what you learned in Part 1 to find and fix the networking problem.

## What you're building

- One VPC (10.0.0.0/16)
- **Two subnets:**
  - Public subnet (10.0.1.0/24) — has a route table with a default route to the Internet Gateway
  - App subnet (10.0.2.0/24) — has its own route table that should also allow outbound traffic to the internet
- One Internet Gateway
- Two route tables (public_rt and app_rt) and two subnet associations

Your job is to run the tests, diagnose the routing issue, and fix the configuration.

## Instructions

1. **Start LocalStack** (from the repo root, if not already running):
   ```bash
   docker compose up -d
   ```

2. **Open this directory** and run Terraform:
   ```bash
   cd part-2-challenge
   terraform init
   terraform test
   ```

3. **Read the test output.** The failing assertions and error messages tell you what is wrong (e.g. which route table is missing a route).

4. **Fix the configuration** in `main.tf`. No walkthrough is provided — use the test messages and your experience from Part 1.

5. **Re-run the tests** until you see all runs pass and **Success!** at the end.

## Hints

- The same kind of routing concept from Part 1 applies here: a subnet needs a default route (0.0.0.0/0) to reach the internet.
- There are two route tables. One is already correct; the other is missing a route.
- The fix is in `main.tf` only; you do not need to change the test file.

## Reference

- **[CONCEPTS.md](../CONCEPTS.md)** (in repo root) — How Terraform, AWS VPC, and routing work.
- Part 1 walkthrough (if you need a reminder of the route block syntax).
