# Part 3: Design + Verify — Write Terraform and Your Own Tests

This part moves from fixing code to authoring it.

You will:
- write Terraform resources in `main.tf` based on the requirements below,
- write your own tests in `vpc_routing.tftest.hcl`,
- prove the network behaves as required.

No walkthrough is provided for this part.

## Requirements

Build a VPC network with these requirements:

1. **VPC**
   - CIDR: `10.0.0.0/16`

2. **Subnets**
   - `web_subnet`: `10.0.1.0/24`
   - `app_subnet`: `10.0.2.0/24`
   - `db_subnet`: `10.0.3.0/24`

3. **Internet Gateway**
   - Attach one IGW to the VPC.

4. **Route tables**
   - Create one route table per subnet (`web_rt`, `app_rt`, `db_rt`).
   - `web_rt` must include a default route `0.0.0.0/0` to the IGW.
   - `app_rt` must include a default route `0.0.0.0/0` to the IGW.
   - `db_rt` must **not** include a default route to the internet.

5. **Associations**
   - Associate each subnet to its matching route table.

## Your testing task

In `vpc_routing.tftest.hcl`, write tests that prove:

1. `web_rt` has at least one route and includes `0.0.0.0/0`.
2. `app_rt` has at least one route and includes `0.0.0.0/0`.
3. `db_rt` does **not** include `0.0.0.0/0`.
4. `web_subnet`, `app_subnet`, and `db_subnet` are each associated with the correct route table.

Use `command = apply` in your test runs so route values are known during assertions.

### Example assertion pattern

```hcl
assert {
  condition     = length([for r in aws_route_table.web_rt.route : r if r.cidr_block == "0.0.0.0/0"]) > 0
  error_message = "ROUTING ERROR: web_rt is missing default route to the Internet Gateway."
}
```

For a negative check (route should not exist), invert the condition with `== 0`.

## Run steps

From this directory:

```bash
terraform init
terraform test
```

Keep iterating until all tests pass with **Success!**.

## Reference

- **[CONCEPTS.md](../CONCEPTS.md)** for Terraform and networking concepts.
