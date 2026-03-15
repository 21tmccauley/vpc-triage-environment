# Test-Driven Cloud Network Architecture: Building & Breaking VPCs Locally

This lab teaches Infrastructure as Code (IaC) and VPC networking by having you **diagnose and fix intentionally broken AWS-style networks** using Terraform and LocalStack—all running locally, with no cloud account or cost.

**Two parts:**

| Part | Folder | Description |
|------|--------|-------------|
| **Part 1 — Walkthrough** | [part-1-walkthrough/](part-1-walkthrough/) | Guided. One VPC, one public subnet, one broken route table. Follow the walkthrough to fix it. |
| **Part 2 — Challenge** | [part-2-challenge/](part-2-challenge/) | On your own. VPC with public and internal subnets; one route table is misconfigured. Use the tests to find and fix it. |

Do **Part 1 first**, then **Part 2**.

---

## Tech stack

- **Docker / Docker Compose** — Runs LocalStack in a container.
- **LocalStack** — Emulates AWS (VPC, subnets, route tables, etc.) on `localhost:4566`.
- **Terraform** — Defines the network in HCL and runs tests (`.tftest.hcl`) that assert routing and associations.

---

## Quick start

1. **Clone this repo.**  
   On **Windows**, use a copy on the WSL filesystem for Terraform (see [Windows + WSL](#windows--wsl) below).

2. **Start LocalStack once** (from the repo root):
   ```bash
   docker compose up -d
   ```

3. **Part 1 — Walkthrough**
   ```bash
   cd part-1-walkthrough
   terraform init
   terraform test
   ```
   Follow the failure messages and the [Part 1 walkthrough](part-1-walkthrough/WALKTHROUGH.md) to fix `main.tf`, then re-run the tests until they pass.

4. **Part 2 — Challenge**
   ```bash
   cd part-2-challenge
   terraform init
   terraform test
   ```
   Fix the misconfiguration using only the test output and what you learned in Part 1. No full walkthrough.

---

## Repository layout

```
vpc-triage-environment/
├── README.md                 ← You are here
├── CONCEPTS.md               ← How Terraform, AWS VPC, and routing work
├── docker-compose.yaml       ← Start LocalStack from repo root
├── part-1-walkthrough/       ← Part 1: guided fix
│   ├── README.md
│   ├── WALKTHROUGH.md        ← Step-by-step instructions
│   ├── main.tf
│   └── vpc_routing.tftest.hcl
└── part-2-challenge/         ← Part 2: challenge (no walkthrough)
    ├── README.md
    ├── main.tf
    └── vpc_routing.tftest.hcl
```

Each part has its own Terraform state. Always run `terraform init` and `terraform test` from inside the part’s directory.

---

## Windows + WSL

On Windows, run Terraform from a directory on the **WSL filesystem**, not from `C:\...` or `/mnt/c/...`, to avoid `chmod: operation not permitted` during `terraform init`.

**Option A — Copy the repo into WSL**

```bash
cp -r /mnt/c/Users/<YourWindowsUsername>/vpc-triage-environment ~/vpc-triage-environment
cd ~/vpc-triage-environment
docker compose up -d
cd part-1-walkthrough && terraform init && terraform test
```

You can still edit files in Cursor on the Windows path; run Terraform from the WSL copy.

**Option B — Use the repo only from WSL**

Clone or move the repo under your WSL home (e.g. `~/vpc-triage-environment`). In Cursor, open that folder via **File → Open Folder** and choose `\\wsl$\Ubuntu\home\<your-username>\vpc-triage-environment`.

---

## Reference

- **[CONCEPTS.md](CONCEPTS.md)** — Terraform workflow, AWS VPC/IGW/subnets/route tables, default routes, and how the tests work.
