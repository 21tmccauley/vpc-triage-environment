# How This Lab Works: Terraform, AWS Services, and Networking

This document explains the concepts behind the lab: how Terraform works, what each AWS resource does, and how the networking fits together.

---

## 1. How Terraform Works

### What Terraform Is

**Terraform** is an **Infrastructure as Code (IaC)** tool. You describe the infrastructure you want in configuration files (written in **HCL**, HashiCorp Configuration Language), and Terraform figures out how to create or change real resources to match that description.

- **Declarative, not imperative:** You say *what* you want (e.g. “a VPC with this CIDR”), not *how* to do it step by step.
- **State:** Terraform keeps a **state file** that records which real resources it manages and their identities. That way it can update or destroy only what it created.
- **Provider:** Terraform talks to cloud APIs (or emulators like LocalStack) through **providers**. This lab uses the **AWS provider**, configured to point at LocalStack instead of real AWS.

### The Terraform Workflow

| Step | Command | What it does |
|------|---------|----------------|
| **Init** | `terraform init` | Downloads the AWS provider and prepares the working directory. |
| **Plan** | `terraform plan` | Compares your `.tf` files to the current state and shows what would change (create, update, destroy). Does *not* change anything. |
| **Apply** | `terraform apply` | Applies the plan: creates or updates resources so reality matches your config. |
| **Test** | `terraform test` | Runs `.tftest.hcl` files: runs one or more **plan** or **apply** steps and checks **assertions** against the result. |

In this lab, **`terraform test`** runs an **apply** (so resources are created or updated in LocalStack), then checks that the route table has the right routes and the subnet is correctly associated. The tests use apply because the route table’s `route` attribute is only known after apply; at plan time it would be “unknown” and the assertions could not run.

### How the Provider Talks to LocalStack

In `main.tf`, the `provider "aws"` block does two important things:

1. **Endpoints:** `endpoints { ec2 = "http://localhost:4566" }` sends all EC2 API calls (including VPC, subnets, route tables) to LocalStack on port 4566 instead of AWS.
2. **Bypasses:** `skip_credentials_validation`, `skip_metadata_api_check`, etc., prevent Terraform from trying to reach real AWS services for auth or metadata.

So when Terraform runs **plan** or **apply**, it uses the same logic as for real AWS, but the API calls go to LocalStack running in Docker.

---

## 2. The AWS Services in This Project

All of these are part of **Amazon VPC (Virtual Private Cloud)** and are exposed through the **EC2 API** (which Terraform’s AWS provider uses for networking resources).

### VPC — Virtual Private Cloud

```hcl
resource "aws_vpc" "main_vpc" { ... }
```

- A **VPC** is an isolated network in AWS (or in LocalStack, in memory).
- You define its address space with a **CIDR block**. Here: `10.0.0.0/16` (65,536 IP addresses from 10.0.0.0 to 10.0.255.255).
- **DNS settings** (`enable_dns_hostnames`, `enable_dns_support`) allow instances in the VPC to use DNS; they’re on for a typical public subnet setup.

Think of the VPC as the top-level “container” for all networking in this lab.

### Internet Gateway (IGW)

```hcl
resource "aws_internet_gateway" "main_igw" { vpc_id = aws_vpc.main_vpc.id }
```

- An **Internet Gateway** attaches to *one* VPC and is the door between that VPC and the public internet.
- It does not get a CIDR; it’s the target for **default routes** (e.g. `0.0.0.0/0`) so that traffic can leave the VPC to the internet (and come back).
- Without an IGW, nothing in the VPC can reach the internet. With an IGW but no route to it, traffic still never reaches it—which is what the lab’s bug demonstrates.

### Subnet

```hcl
resource "aws_subnet" "public_subnet" { vpc_id = ..., cidr_block = "10.0.1.0/24", ... }
```

- A **subnet** is a slice of the VPC’s CIDR. This one uses `10.0.1.0/24` (256 addresses: 10.0.1.0–10.0.1.255).
- It lives inside the VPC and must fit inside the VPC’s CIDR.
- **Public subnet** in practice means: we intend to send traffic from this subnet to the internet via the IGW. “Public” is determined by **routing**, not by the subnet resource alone. Here we also set `map_public_ip_on_launch = true` so that instances (if we added any) could get a public IP.

### Route Table

```hcl
resource "aws_route_table" "public_rt" { vpc_id = aws_vpc.main_vpc.id, ... }
```

- A **route table** holds **routes**: rules that say “traffic to *this* destination goes to *this* target.”
- Each route has a **destination** (CIDR) and a **target** (e.g. an Internet Gateway, a NAT Gateway, or a local gateway).
- Every VPC has an implicit default route table; we create an explicit one so we can control exactly which routes the public subnet uses.

**The lab’s intentional bug:** The route table is created but has **no routes** (or at least no default route). So even though the IGW exists, the route table never sends traffic to it.

### Route Table Association

```hcl
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
```

- A **route table association** links a **subnet** to a **route table**.
- One subnet can be associated with only one route table at a time; one route table can be associated with many subnets.
- Traffic leaving the subnet is evaluated against that route table’s routes. So the public subnet’s outbound path is determined by `public_rt`.

### How They Relate

```
VPC (10.0.0.0/16)
├── Internet Gateway (attached to VPC)
├── Subnet "public" (10.0.1.0/24)
│   └── associated with → Route Table "public_rt"
└── Route Table "public_rt"
    └── should contain route: 0.0.0.0/0 → Internet Gateway
```

If the route table has no default route to the IGW, the subnet has no path to the internet.

---

## 3. How the Networking Works

### CIDR in This Lab

| Resource   | CIDR            | Meaning |
|-----------|------------------|--------|
| VPC       | `10.0.0.0/16`   | All addresses from 10.0.0.0 to 10.0.255.255. |
| Subnet    | `10.0.1.0/24`   | Addresses 10.0.1.0–10.0.1.255 (inside the VPC). |

The subnet’s range must be fully inside the VPC’s range.

### The Default Route: 0.0.0.0/0

- **0.0.0.0/0** means “all IPv4 addresses.” So a route with destination `0.0.0.0/0` is the **default route**: “send everything that doesn’t match a more specific route here.”
- In a typical public subnet, that route points to the **Internet Gateway**. So:
  - Traffic to the internet (e.g. 8.8.8.8) doesn’t match a more specific route in the table → it uses the default route → goes to the IGW → out to the internet.
- If the route table has **no** default route to the IGW, traffic destined for the internet has nowhere to go and is dropped (or not sent). That’s the “network outage” the tests are detecting.

### Traffic Flow (When Fixed)

1. An instance (or simulated traffic) in the **public subnet** (10.0.1.x) sends a packet to the internet (e.g. 8.8.8.8).
2. The VPC routing logic looks at the **route table associated with that subnet** (`public_rt`).
3. The route table should have a route: **0.0.0.0/0 → Internet Gateway**.
4. The packet is sent to the IGW, which forwards it out (and back) to the internet.

If step 3 is missing (no 0.0.0.0/0 route to the IGW), step 4 never happens and the subnet has no internet connectivity.

### What the Tests Are Checking

- **verify_public_routing:** The route table has at least one route, and one of them is a default route (0.0.0.0/0) to the Internet Gateway.
- **verify_subnet_association:** The public subnet is associated with the intended route table.

Fixing the lab means adding the missing `route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.main_igw.id }` block to `aws_route_table.public_rt` so that the applied infrastructure matches what the tests expect.

---

## Summary

| Concept | In this lab |
|--------|--------------|
| **Terraform** | Declarative IaC; plan/test run against LocalStack via the AWS provider. |
| **VPC** | Isolated network 10.0.0.0/16. |
| **IGW** | Gateway attached to the VPC for internet access. |
| **Subnet** | 10.0.1.0/24 slice of the VPC, associated with one route table. |
| **Route table** | Must contain 0.0.0.0/0 → IGW so the subnet can reach the internet. |
| **Networking** | Subnet → route table → default route → IGW → internet. |

Once the default route is added in `main.tf`, the design is correct and `terraform test` should pass.
