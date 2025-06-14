# SSH key pair for the bastion host
resource "aws_key_pair" "ce_task_key" {
  key_name   = "${var.project_name}-${var.environment}-bastion-key"
  public_key = data.aws_ssm_parameter.bastion_public_key.value
}

# Security group for the bastion host
# Controls inbound and outbound traffic for secure access
resource "aws_security_group" "bastion_sg" {
  name   = "${var.project_name}-${var.environment}-bastion-sg"
  vpc_id = var.vpc_id

  # Allow inbound SSH (port 22) access from the specified IP address
  # Restricts access to the user's IP for security
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_bastion_access
  }

  # Allow all outbound traffic from the bastion host
  # Necessary for the bastion to connect to RDS and other services
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for the bastion host
# Provides a secure entry point to access resources in private subnets (e.g., RDS)
resource "aws_instance" "bastion" {
  ami                         = "ami-045e7795f0bdf93b6"
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.ce_task_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
  }
}