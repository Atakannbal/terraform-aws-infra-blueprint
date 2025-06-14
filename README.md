# 📘 AWS Infrastructure blueprint with Terraform

```
⚠️  This project is currently under development.
```

## 📝 Overview
This project provisions a full-stack application infrastructure on AWS using Terraform. It focuses on infrastructure as code, automating the deployment of networking, compute, storage, CI/CD, monitoring, and security resources. The stack includes a React frontend, Java backend, and PostgreSQL database, all orchestrated with modern AWS and Kubernetes services for scalability and maintainability.

## ⚙️ Pre-requisites
1. 🏗️ Terraform
2. 🐍 Python 3.8+
3. ☁️ AWS CLI installed and configured

## 🧩 Components
- 🎨 Frontend: A simple React app (webpack + nginx)
- 🖥️ Backend: A simple Java http server
- 🗄️ Database: PostgreSQL

## 🛠️ Services used
Amazon VPC 🌐, Elastic Load Balancing (ELB) 🏞️, AWS CloudFront 🌐, AWS Route 53 🛰️, Bastion Host (EC2) 🛡️, Amazon EC2 🖥️, Amazon ECR 🐳, Amazon EKS ☸️, AWS CodeBuild 🛠️, AWS CloudWatch 📊, AWS KMS 🗝️, Amazon RDS 🗄️, AWS Secrets Manager 🔐, AWS SNS 📣, Kubernetes Add-ons (Cluster Autoscaler, Metrics Server, HPA, External Secrets) ⚙️

## 🏗️ Architecture

1. **Networking & DNS**
    - Amazon VPC with public and private subnets for network isolation
    - NAT Gateway for outbound internet access from private subnets
    - AWS Route 53 for DNS management
    - Bastion Host (EC2) in public subnet for secure access to private resources

2. **Load Balancing & CDN**
    - Elastic Load Balancer (ELB) for distributing traffic to frontend services
    - AWS CloudFront as a CDN in front of the load balancer for global content delivery

3. **Compute**
    - Amazon EKS (Kubernetes) cluster in private subnets
    - EC2 nodes managed by EKS for running application pods
    - Amazon ECR for storing Docker images
    - Bastion Host (EC2) for administrative access

4. **Application Layer**
    - Frontend: React app served via Nginx, deployed as a Kubernetes deployment
    - Backend: Java HTTP server, deployed as a Kubernetes deployment
    - Ingress managed via Kubernetes (external-dns, ingress controller)

5. **Database & Secrets**
    - Amazon RDS (PostgreSQL) in private subnets, encrypted with KMS
    - AWS Secrets Manager for storing and managing database credentials
    - External Secrets Operator for syncing secrets to Kubernetes

6. **CI/CD & Automation**
    - AWS CodeBuild for building and deploying application images
    - Automated deployment pipelines integrated with ECR and EKS

7. **Monitoring & Autoscaling**
    - AWS CloudWatch for logging and monitoring
    - Kubernetes Metrics Server and HPA for pod autoscaling
    - Cluster Autoscaler for node autoscaling
    - AWS SNS for alerting

## 🛠️ Flow
1. User accesses the application via a custom domain managed by Route 53.
2. Requests are routed through AWS CloudFront (CDN) for caching and global delivery.
3. CloudFront forwards traffic to the Elastic Load Balancer (ELB).
4. ELB distributes requests to frontend pods (React + Nginx) running in private subnets on EKS.
5. Nginx serves static assets and proxies API requests to backend pods (Java server) in the same EKS cluster.
6. Backend pods interact with Amazon RDS (PostgreSQL) for data storage, using credentials managed by AWS Secrets Manager and synced to Kubernetes via External Secrets.
7. Monitoring, autoscaling, and alerting are handled by CloudWatch, Kubernetes Metrics Server, HPA, Cluster Autoscaler, and SNS.

## 🔍 Useful Snippets

### Apply using tfvars
`terraform apply -var-file="apply-tfvars/prod.tfvars"`

### Connecting local kubectl to EKS
`aws eks update-kubeconfig --name ce-task-prod-eks-cluster --region eu-central-1`

### Getting the external IP for LB
`kubectl get svc frontend-service -o wide`

### Getting HPA status
`kubectl get hpa backend-hpa -n default`

### Getting pod CPU and memory usage
`kubectl top pods -n default`

### Displaying security groups
`aws ec2 describe-security-groups --region eu-central-1 --filters Name=vpc-id,Values=<vpc_id>`

### Deleting security group
`aws ec2 delete-security-group --group-id <sg>`

### Checking Terraform logs
`export TF_LOG=DEBUG`
`terraform destroy 2>&1 | tee destroy.log`

### Check for NS records
`dig www.example.com NS`

### List all node groups in cluster
`aws eks list-nodegroups --cluster-name ce-task-prod-eks-cluster --region eu-central-1`

### Describe a specific node group:
`aws eks describe-nodegroup --cluster-name ce-task-prod-eks-cluster --nodegroup-name default-2025061310573813980000000e --region eu-central-1`

### Check the max pod capacity of EKS nodes
`kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, maxPods: .status.allocatable.pods}'`