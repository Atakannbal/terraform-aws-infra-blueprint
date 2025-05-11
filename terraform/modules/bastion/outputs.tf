output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

# Output the SSH command to connect to the bastion
output "bastion_ssh_command" {
  value       = "ssh -i ${path.module}/bastion-key ec2-user@${aws_instance.bastion.public_ip}"
  description = "Command to SSH into the bastion host"
}