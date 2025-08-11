# ECS Fargate Infrastructure on AWS

This repository contains the Terraform code and CI/CD workflows to provision and deploy a highly available **ECS Fargate** application in AWS using an **Application Load Balancer (ALB)**, **Route 53** DNS, and **ACM** TLS/SSL certificates.


## 🧩 Application: Gatus Health Checker

This stack runs **[Gatus](https://github.com/TwiN/gatus)** as a lightweight uptime and health monitoring dashboard.  
- The service uses the **latest public Gatus image (`:latest`)**, mirrored/pulled via our ECR registry for deployment.  
- The ALB target group is configured for HTTP health checks on `/`, and the ECS service runs in private subnets behind the ALB.  
- I’ll add **future personal projects** to Gatus so this dashboard becomes the single place to see status across everything I host.

## 🔗 Accessing the Application

- **URL:** https://zakariagatus.click  
- HTTP automatically **redirects to HTTPS** (ACM certificate on the ALB). 


## 🏗 Architecture Diagram

![Architecture Diagram](./readmefiles/ecsproject.drawio%20(5).png)

## 📜 Overview

The infrastructure provisions:

- **VPC** with:
  - 2 public subnets (one per AZ) for ALB and NAT Gateways
  - 2 private subnets (one per AZ) for ECS Fargate tasks
- **Public NACLs** for subnet-level filtering
- **Internet Gateway** for inbound access to ALB and outbound via NAT
- **NAT Gateway** for ECS outbound to AWS services (ECR, CloudWatch, etc.)
- **Security Groups** to restrict inbound/outbound traffic between ALB and ECS
- **ECS Cluster & Service** running Fargate tasks behind an ALB
- **Application Load Balancer (ALB)** with:
  - HTTP (80) → HTTPS (443) redirect
  - HTTPS listener with ACM certificate
  - Target group (IP mode) for ECS tasks
- **Route 53** hosted zone for DNS (alias record pointing to ALB)
- **ACM** TLS certificate for HTTPS
- **ECR** repository for application images
- **CloudWatch Logs** for container logging
- **Terraform remote state** in S3 + DynamoDB lock table