resource "aws_security_group" "ecs_sg" {
  name        = "ecs_security"
  description = "ecs container security"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "-1"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.public_subnet_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}