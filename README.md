# Terraform -- EC2 with SSM-only Access (No SSH)

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-blue?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws)](https://aws.amazon.com/)

## Overview

This project demonstrates how to provision a **fully disposable EC2
instance** on AWS using **Terraform only**, with **no SSH access**, **no
inbound network exposure**, and **access exclusively via AWS Systems
Manager (SSM)**.

The objective is to follow an **immutable infrastructure mindset**: - no
manual configuration - no persistent state - safe destruction at any
time

This setup is intentionally minimal and focused on **core DevOps
fundamentals**.

------------------------------------------------------------------------

## Architecture & Design Principles

-   **Compute**: 1 × EC2 (Amazon Linux 2023)
-   **Access**: AWS SSM Session Manager only
-   **Networking**:
    -   Default VPC and subnets
    -   Security Group with **no ingress rules**
-   **Identity & Access**:
    -   IAM Role attached to the EC2
    -   Managed policy: `AmazonSSMManagedInstanceCore`
-   **Provisioning**:
    -   Terraform only
    -   Automated bootstrapping via `user_data`
-   **Lifecycle**:
    -   Fully reproducible
    -   Safe to destroy without data loss

------------------------------------------------------------------------

## Key Features

-   ❌ No SSH key
-   ❌ No port 22
-   ❌ No inbound traffic
-   ✅ IAM-based access via SSM
-   ✅ Automated service installation
-   ✅ Cloud-init / user-data driven configuration
-   ✅ Stateless and disposable EC2 instance

------------------------------------------------------------------------

## Terraform Resources

The project creates the following AWS resources:

-   Uses the **default VPC** and **default subnets**
-   A **Security Group** allowing **only outbound traffic**
-   An **IAM Role** assumed by the EC2 instance
-   Attachment of the managed policy:
    -   `AmazonSSMManagedInstanceCore`
-   An **IAM Instance Profile** (required for EC2 + SSM)
-   An **EC2 instance** with:
    -   Amazon Linux 2023 AMI (resolved dynamically)
    -   Explicit installation and activation of the SSM agent
    -   Automatic installation and startup of Nginx

------------------------------------------------------------------------

## user_data Behavior

At boot time, the EC2 instance performs the following actions:

-   System update
-   Explicit installation and startup of the **amazon-ssm-agent**
-   Installation and activation of **nginx**
-   Creation of a basic HTML page

This ensures that **every instance recreation results in an identical
system state**.

------------------------------------------------------------------------

## Inputs

  Variable       Description                               Default
  -------------- ----------------------------------------- -------------
  `aws_region`   AWS region where resources are deployed   `eu-west-1`

------------------------------------------------------------------------

## Outputs

  Output          Description
  --------------- -----------------------------------------
  `instance_id`   EC2 instance ID
  `public_ip`     Public IP address (for visibility only)

------------------------------------------------------------------------

## Usage

``` bash
terraform init
terraform apply
```

Once deployed, connect to the instance using **Session Manager**:

-   AWS Console → EC2 → Connect → Session Manager\
-   or via AWS CLI:

``` bash
aws ssm start-session --target <INSTANCE_ID>
```

------------------------------------------------------------------------

## Destruction

The infrastructure can be safely destroyed at any time:

``` bash
terraform destroy
```

No data or configuration is lost, as the EC2 instance is designed to be
**fully ephemeral**.

------------------------------------------------------------------------

## Learning Outcomes

This project reinforces several key DevOps concepts:

-   EC2 instances are **disposable resources**, not pets
-   IAM is a stronger security boundary than network access
-   `user_data` replaces manual configuration
-   Terraform replaces click-based provisioning
-   Destruction is a normal and safe operation

------------------------------------------------------------------------

## Disclaimer

This project is intentionally minimal and designed for **learning and
experimentation**, not production use.
