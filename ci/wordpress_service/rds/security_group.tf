resource "aws_security_group" "rds_sg" {
  name        = "rds_security"
  description = "RDS datbase security"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "-1"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}