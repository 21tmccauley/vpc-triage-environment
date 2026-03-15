# Test-Driven Cloud Network Architecture: Building & Breaking VPCs Locally

Welcome to the Test-Driven VPC Lab! This project demonstrates how to use Infrastructure as Code (IaC) to provision, test, and troubleshoot cloud networks entirely locally. 

By leveraging **Terraform's native testing framework** and **LocalStack**, this lab simulates a real-world DevOps environment where infrastructure is treated like software—without requiring paid AWS accounts or remote deployments.

##  Architecture & Tech Stack
* **Docker & Docker Compose:** Containerizes the local cloud environment.
* **LocalStack:** Emulates AWS services (EC2, VPC, Networking) locally on port 4566.
* **Terraform (HCL):** Provisions the infrastructure and executes test-driven assertions (`.tftest.hcl`).

##  The Scenario
The repository contains a starter `main.tf` file that provisions a standard AWS Virtual Private Cloud (VPC), a public subnet, and an Internet Gateway. However, **there is an intentional routing misconfiguration**. 

Your goal is to run the automated tests, read the failure output to diagnose the network outage, and patch the Terraform code to restore connectivity.

##  Quick Start
1. Clone this repository. **If you're on Windows with WSL,** use the copy under your WSL home directory (see [Setup: Windows + WSL](#setup-windows--wsl) below) so Terraform runs correctly.
2. Ensure Docker Desktop is running.
3. Start the local cloud: `docker compose up -d`
4. Initialize Terraform: `terraform init`
5. Run the tests: `terraform test` — they will fail because the VPC routing is misconfigured.
6. Read the test output to see which assertions failed, then fix the Terraform in `main.tf` (the route table is missing a default route to the Internet Gateway).
7. Re-run `terraform test` until all assertions pass.

### Setup: Windows + WSL
On Windows, run Terraform from a directory on the **WSL (Linux) filesystem**, not from your Windows drive (e.g. not from `C:\Users\...` or `/mnt/c/...`). The Windows filesystem doesn't support the file permissions Terraform needs when installing providers, which can cause `chmod: operation not permitted` during `terraform init`.

**Option A — Copy the project into WSL (recommended)**  
From your WSL terminal, copy the repo into your home directory and run all commands there:

```bash
cp -r /mnt/c/Users/<YourWindowsUsername>/vpc-triage-environment ~/vpc-triage-environment
cd ~/vpc-triage-environment
```

Then run the Quick Start steps (e.g. `docker compose up -d`, `terraform init`, `terraform test`) from `~/vpc-triage-environment`. You can still edit files in Cursor/VS Code on the Windows path; just run Terraform from the WSL copy.

**Option B — Use the project only from WSL**  
Clone or move the repo so it lives only under your WSL home (e.g. `~/vpc-triage-environment`). Open that folder in Cursor via **File → Open Folder** and choose `\\wsl$\Ubuntu\home\<your-wsl-username>\vpc-triage-environment` so your project and Terraform both use the Linux filesystem.
