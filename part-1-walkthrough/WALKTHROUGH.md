# Part 1 Walkthrough — Step by Step

This walkthrough leads you through fixing the broken VPC routing in Part 1.

---

## Step 1: Run the tests

From the `part-1-walkthrough` directory:

```bash
terraform init
terraform test
```

You should see **verify_public_routing** fail with messages like:

- **NETWORK OUTAGE:** The public route table is empty.
- **ROUTING ERROR:** The route table is missing a default route (0.0.0.0/0) pointing to the Internet Gateway.

**verify_subnet_association** should pass.

---

## Step 2: Find the right resource

The errors point to the **route table** and the fact that it has no routes (or no default route). In `main.tf`, the route table is:

```hcl
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  # ... no route { } blocks here — that's the bug!

  tags = {
    Name = "lab-public-rt"
  }
}
```

A public subnet needs a **default route** (0.0.0.0/0) that sends traffic to the **Internet Gateway** so instances can reach the internet.

---

## Step 3: Add the missing route

Inside the `aws_route_table "public_rt"` block, add a `route` block that sends all non-local traffic to the IGW:

- **Destination:** `0.0.0.0/0` (default route = “all IPv4 addresses”).
- **Target:** The Internet Gateway already defined in this file: `aws_internet_gateway.main_igw.id`.

In HCL, that looks like:

```hcl
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main_igw.id
}
```

Place this **inside** the `resource "aws_route_table" "public_rt"` block (e.g. after `vpc_id`, before `tags`).

---

## Step 4: Verify

Run the tests again:

```bash
terraform test
```

You should see:

- **verify_public_routing** — pass  
- **verify_subnet_association** — pass  
- **Success!** at the end  

---

## Why this fix works

- The **route table** controls where traffic from the subnet goes.
- Without a **default route** (0.0.0.0/0), traffic to the internet has no path and is dropped.
- By adding a route with **gateway_id = aws_internet_gateway.main_igw.id**, you send that traffic to the Internet Gateway, which connects the VPC to the internet.

For more on VPCs, route tables, and default routes, see **[CONCEPTS.md](../CONCEPTS.md)** in the repo root.
