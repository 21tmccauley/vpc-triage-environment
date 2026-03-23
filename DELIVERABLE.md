# Part 1 Deliverable - Terraform and VPC Basics

**Name:**
**Date:**

## Submission Checklist

- [ ] I ran `terraform init` successfully
- [ ] I completed Part 1 and ran `terraform test` (fixed failing tests)
- [ ] I completed Part 2 challenge and ran `terraform test` (fixed failing tests)
- [ ] I included screenshots showing passing tests for Part 1 and Part 2
- [ ] I answered all questions in this document

---

## Part A - Terraform Fundamentals

Answer in complete sentences.

1. In your own words, what is Terraform and what problem does it solve?
**Answer:**

2. What is "Infrastructure as Code" (IaC), and why is it useful in team environments?
**Answer:**

3. What is the difference between `terraform init`, `terraform plan`, and `terraform apply`?
**Answer:**

4. In this lab, what does `terraform test` validate?
**Answer:**

5. Why is it useful that tests failed first before the fix?
**Answer:**

---

## Part B - Networking Concepts (From This Lab)

Use examples from your `main.tf`.

1. What is the CIDR block of the VPC, and what does that represent?
**Answer:**

2. What is the CIDR block of the subnet, and how does it relate to the VPC CIDR block?
**Answer:**

3. What is the role of an Internet Gateway in a VPC?
**Answer:**

4. What does a route table do?
**Answer:**

5. What does the route `0.0.0.0/0` mean?
**Answer:**

6. Why did the missing route cause the test to fail?
**Answer:**

7. Which resource connects the subnet to the route table in this assignment?
**Answer:**

---

## Part C - Debugging and Fix Reflection

1. What exact change did you make to fix the failing test?
**Answer:**

2. Which test failed first, and what did the error message tell you?
**Answer:**

3. How did you confirm your fix was correct?
**Answer:**

---

## Part D - Evidence (Screenshots Required)

Add screenshots below.

### Required Screenshot 1 - Initial Failure

- Show the first `terraform test` run with at least one failure.
- The error text should be readable.

### Required Screenshot 2 - Successful Test Run

- Show a `terraform test` run where all tests pass.
- Must include the final success output.

### Code Fix in `main.tf`

- Show the route block that fixed the issue.

---

## Part E - Part 1 Command Log

List the commands you ran for Part 1 in order.

```bash
# Example:
# terraform init
# terraform test
```

---

## Part F - Part 2 Challenge (Public + Internal Subnets)

Answer in complete sentences.

1. When you first ran `terraform test` in `part-2-challenge/`, which assertion(s) failed, and what did the error message say?
**Answer:**

2. Which route table was missing the `0.0.0.0/0` default route, and how do you know? (Use the test output and/or your `main.tf`.)
**Answer:**

3. What exact change did you make in `part-2-challenge/main.tf` to fix the failing test(s)?
**Answer:**

4. Explain why the internal subnet also needs a default route to the Internet Gateway in this lab. (Relate your answer to outbound traffic.)
**Answer:**

---

## Part G - Part 2 Evidence (Screenshots Required)

### Required Screenshot 1 - Part 2 Initial Failure

- Show the first `terraform test` run in `part-2-challenge/` with at least one failure.
- The error text should be readable.

### Required Screenshot 2 - Part 2 Successful Test Run

- Show a `terraform test` run in `part-2-challenge/` where all tests pass.
- Must include the final success output.

### Optional Screenshot 3 - Part 2 Code Fix in `main.tf`

- Show the `route` block that fixed the issue (typically inside the internal route table).

---

## Part H - Part 2 Command Log

List the commands you ran for Part 2 in order.

```bash
# Example:
# cd part-2-challenge
# terraform init
# terraform test
```
