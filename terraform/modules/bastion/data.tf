data "aws_ssm_parameter" "bastion_public_key" {
  name = "/bastion/public-key"
}