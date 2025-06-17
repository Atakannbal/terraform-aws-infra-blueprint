#########################################################################################
# This module provisions a secure bastion host (jump box) in the specified VPC.
# Includes EC2 instance, SSH key pair, and security group rules for controlled access.
# The bastion allows secure SSH access to private resources (e.g., RDS, EKS nodes).
##########################################################################################

resource "aws_instance" "bastion" {
  ami                         = "ami-045dbe03c5652f049"
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.ce_task_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
  }
}

resource "aws_key_pair" "ce_task_key" {
  key_name   = "${var.project_name}-${var.environment}-bastion-key"
  public_key = data.aws_ssm_parameter.bastion_public_key.value
}

resource "aws_security_group" "bastion_sg" {
  name   = "${var.project_name}-${var.environment}-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_bastion_access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = var.eks_node_security_group_id
}