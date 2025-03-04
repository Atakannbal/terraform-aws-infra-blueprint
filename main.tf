variable "my_ip" {
  description = "My public IP adress for SSH and database access"
  type = string
  default = "176.88.142.54/32"
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"] 

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ecr_repository" "ce-task-backend-ecr" {
  name = "ce-task-backend"
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

resource "aws_ecr_repository" "ce-task-frontend-ecr"{
  name = "ce-task-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

data "aws_iam_role" "eks_node_role" {
  name = module.eks.eks_managed_node_groups["default"].iam_role_name
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_readonly" {
  role       = data.aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.0"
  name               = "ce-task-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-central-1a", "eu-central-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/ce-task-eks-cluster" = "shared"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19"
  cluster_name    = "ce-task-eks-cluster"
  cluster_version = "1.31"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  eks_managed_node_groups = {
    default = {
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      instance_types = ["t3.micro"]
    }
  }
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = [var.my_ip]
}

resource "aws_security_group" "backend_sg" {
  name   = "ce-task-backend-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "rds" {
  source                 = "terraform-aws-modules/rds/aws"
  version                = "~> 6.0"
  identifier             = "ce-task-calculator-db"
  engine                 = "postgres"
  engine_version         = "15"
  family                 = "postgres15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "calculator"
  username               = "atakbal"
  password               = random_password.rds_password.result
  port                   = 5432
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_ids             = module.vpc.private_subnets
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  manage_master_user_password = false
  # Backup
  backup_retention_period = 1
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "ce-task-rds-enhanced-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "rds_key_alias" {
  name                    = "alias/ce-task-rds-key"
  target_key_id           = aws_kms_key.rds_key.key_id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "ce-task-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Name = "ce-task-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "ce-task-rds-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id, module.eks.cluster_security_group_id, module.eks.node_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_secretsmanager_secret" "db_credentials" {
  name = "ce-task-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = "{\"username\":\"${module.rds.db_instance_username}\",\"password\":\"${random_password.rds_password.result}\",\"host\":\"${module.rds.db_instance_endpoint}\",\"dbname\":\"${module.rds.db_instance_name}\"}"
}


resource "aws_key_pair" "ce_task_key" {
  key_name   = "ce-task-key"
  public_key = file("${path.module}/ce-task-key.pub")
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = "ce-task-key"
  associate_public_ip_address = true

  tags = {
    Name = "ce-task-bastion"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "ce-task-bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "bastion_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}
output "frontend_ecr_repository_url" {
  value = aws_ecr_repository.ce-task-frontend-ecr.repository_url
}

output "backend_ecr_repository_url" {
  value = aws_ecr_repository.ce-task-backend-ecr.repository_url
}