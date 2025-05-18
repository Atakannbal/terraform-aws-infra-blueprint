# 🚀 AWS EKS Infrastructure & App Deployment with Terraform

## 📝 Overview
Deployment of an application on AWS with a frontend, backend, and PostgreSQL database.
Focus is on infrastructure over app complexity.

## ⚙️ Pre-requisites
1. 🏗️ Terraform
2. 🐍 Python 3.8+
3. ☁️ AWS CLI installed and configured

## 🧩 Components
- 🎨 Frontend: A simple React app (webpack + nginx)
- 🖥️ Backend: A simple Java http server
- 🗄️ Database: PostgreSQL

## 🛠️ Services used
Amazon EKS ☸️, Amazon RDS 🗄️, AWS Secrets Manager 🔐, Amazon VPC 🌐, Elastic Load Balancing (ELB) 🏞️, Amazon EC2 🖥️, AWS CodeBuild 🛠️, AWS KMS 🗝️, AWS CloudWatch 📊

## 🏗️ Architecture

1. **Networking (VPC)**
    - 🌍 Public Subnets: Host NAT Gateway, ELB for frontend
    - 🔒 Private Subnets: Host EKS nodes (pods), RDS
    - 🚪 NAT Gateway: Outbound internet access for private subnets

2. **Compute (EKS)**
    - 🖥️ 2 `t3.micro` nodes, each 4 pods.
    - 🧩 Pods: `aws-node` (2), `kube-proxy` (2), `coredns` (1), `backend` (1), `frontend` (1)

3. **Storage (RDS)**
    - 🗄️ PostgreSQL in private subnets, secured by SG.

4. **Secrets (Secrets Manager)**
    - 🔐 Stores DB credentials

## 🛠️ Flow
Browser -> `frontend-external-ip` -> ELB Routes the inbound traffic from the internet to the frontend pods in private subnets -> Nginx serves the UI and proxies to `backend-service` -> Backend writes to RDS -> RDS Stores the data with encryption at rest

## 🛠️ Some of the problems faced during development with solutions applied
1. `FATAL: password authentication failed` - Secrets Manager and RDS password diverged 
 - Even if you set a password in RDS module, it uses its own managed password; in this case, I used master password (temporarily) then set `manage_master_user_password = false` to use pre-defined credentials for a while. However, that breaks credential rotation. With that concern, later I set `manage_master_user_password = true` again.
2. Pod capacity limit `t3.micro` 4-pod limit blocked frontend pod init (pending state)
 - Scaled to 2 nodes
3. Security group misconfiguration initial `main.tf` omitted `node_security_group_id``
 - Included node SG for pod-to-resource traffic in EKS
4. CORS error `fetch('http://backend-service:8080')` failed CORS
 - Nginx proxy `/sum` in frontend pod
5. Initial EKS cluster started at Kubernetes 1.28 caused unexpected cost increase due to extended support
 - Updated cluster version to 1.29 first then 1.30
6. Terraform is great at creating resources, but not the best at deleting/cleaning-up those resources
-  Terraform is not able to delete dynamically externally created security groups and resources. Went into the AWS console and delete the same resource myself. I found out that this happens for VPC. Later, I added some bash scripts in util folder `delete-elbs.sh`, `delete-security-groups.sh`, `delete-detached-enis.sh`. This got easier after enabling feature flags (`enable_xyz_module = true/false`) in tfvars. Since I can use `terraform apply` instead of `terraform destroy` to destroy modules. 
7. Install PostgreSQL on AL2
- sudo yum update
- sudo yum search "postgres"
- todo: use user data to install PostgreSQL or save ami

8. RDS Query Editor limited to Aurora services
- no solution yet, try migrating the database to Aurora
9. `Error syncing load balancer: could not find any suitable subnets``
- EKS identifies its associated subnets by looking for tags with cluster name. Make sure they match.
`    "kubernetes.io/cluster/${var.cluster_name}" = "shared" `

## 🔍 Useful Snippets

### Connecting local `kubectl` to EKS
`aws eks update-kubeconfig --name ce-task-prod-eks-cluster --region eu-central-1`

### Getting the external IP for LB
`kubectl get svc frontend-service -o wide`

### Getting HPA status
`kubectl get hpa backend-hpa -n default`

### Getting pod CPU and memory usage
`kubectl top pods -n default`

### Displaying security groups
`aws ec2 describe-security-groups --region eu-central-1 --filters Name=vpc-id,Values=vpc-07b0d74b5ac63daa0`

### Deleting security group
`aws ec2 delete-security-group --group-id sg-12345678`

### Checking Terraform logs
`export TF_LOG=DEBUG`
`terraform destroy 2>&1 | tee destroy.log`

### Check for NS records
`dig ce-project-aws.atakanbal.com NS`